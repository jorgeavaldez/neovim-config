const assert = require("node:assert/strict");
const { spawn, spawnSync } = require("node:child_process");
const { randomUUID } = require("node:crypto");
const { once } = require("node:events");
const { existsSync, mkdtempSync, readFileSync, readdirSync, renameSync, rmSync, writeFileSync } = require("node:fs");
const { tmpdir } = require("node:os");
const { join, resolve } = require("node:path");
const { test } = require("node:test");
const { setTimeout: delay } = require("node:timers/promises");

const wrapper = resolve(__dirname, "../bin/pi-nvim-editor");
const rpcModule = resolve(__dirname, "../lua/jorge/pi_edit_rpc.lua");

async function waitFor(condition) {
  const deadline = Date.now() + 5000;
  while (Date.now() < deadline) {
    if (condition()) return;
    await delay(25);
  }
  assert.fail("Timed out waiting for Neovim RPC state");
}

test("portable editor client and real Neovim host", { timeout: 45000 }, async (t) => {
  const root = mkdtempSync(join(tmpdir(), "pi editor rpc "));
  const server = process.platform === "win32" ? `\\\\.\\pipe\\pi-editor-${randomUUID()}` : join(root, "host.sock");
  const ready = join(root, "ready");
  const env = {
    ...process.env,
    HOME: process.platform === "win32" ? undefined : root,
    USERPROFILE: root,
    HOMEDRIVE: undefined,
    HOMEPATH: undefined,
    NVIM_APPNAME: "pi-editor-test",
    LOCALAPPDATA: join(root, "localappdata"),
    XDG_CONFIG_HOME: join(root, "config"),
    XDG_STATE_HOME: join(root, "state"),
    XDG_DATA_HOME: join(root, "data"),
    XDG_CACHE_HOME: join(root, "cache"),
    NVIM: server,
    VIMINIT: undefined,
    PI_RPC_MODULE: rpcModule,
    PI_RPC_READY: ready,
  };
  const host = spawn("nvim", ["--headless", "-u", "NONE", "-i", "NONE", "--listen", server,
    "-c", "lua dofile(vim.env.PI_RPC_MODULE).setup(); vim.fn.writefile({'ready'}, vim.env.PI_RPC_READY)"],
    { env, stdio: "ignore", timeout: 40000 });
  const hostClosed = once(host, "close");
  t.after(async () => {
    host.kill();
    await hostClosed;
    rmSync(root, { recursive: true, force: true });
  });
  await waitFor(() => existsSync(ready));
  const requests = join(root, "state", "pi-nvim-rpc", "requests");
  const acks = join(root, "state", "pi-nvim-rpc", "acks");
  const file = join(root, "draft with spaces & unicode ü.md");

  function remote(expression) {
    const result = spawnSync("nvim", ["--headless", "--server", server, "--remote-expr", expression], {
      env, encoding: "utf8", timeout: 3000,
    });
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  }

  function startClient(overrides = {}) {
    const client = spawn(process.execPath, [wrapper, "+2", file], {
      env: { ...env, ...overrides }, stdio: "pipe", timeout: 12000,
    });
    let stderr = "";
    client.stdout.resume();
    client.stderr.on("data", (chunk) => { stderr += chunk; });
    const closed = once(client, "close");
    t.after(() => client.kill());
    return { closed, stderr: () => stderr };
  }

  for (const [command, expected] of [["PiEditCommit", 0], ["wq", 0], ["PiEditAbort", 1], ["q!", 1], ["bd!", 1]]) {
    await t.test(command, async () => {
      writeFileSync(file, "first\nsecond\n");
      const client = startClient();
      await waitFor(() => readdirSync(acks).some((name) => name.endsWith(".json") && JSON.parse(readFileSync(join(acks, name), "utf8")).status === "opened"));
      assert.equal(remote("line('.')"), "2");
      assert.equal(remote("luaeval('vim.api.nvim_buf_get_name(0)')").replaceAll("\\", "/"), file.replaceAll("\\", "/"));
      remote("setline(2, 'edited')");
      remote(`execute('${command}')`);
      const [code] = await client.closed;
      assert.equal(code, expected, client.stderr());
      assert.equal(readFileSync(file, "utf8"), expected === 0 ? "first\nedited\n" : "first\nsecond\n");
      assert.deepEqual(readdirSync(requests), []);
      assert.deepEqual(readdirSync(acks), []);
    });
  }

  await t.test("malformed acknowledgement fails closed", async () => {
    const client = startClient();
    await waitFor(() => readdirSync(acks).some((name) => name.endsWith(".json")));
    const ack = join(acks, readdirSync(acks).find((name) => name.endsWith(".json")));
    writeFileSync(`${ack}.tmp`, JSON.stringify({ version: 1, id: "wrong", status: "committed" }));
    renameSync(`${ack}.tmp`, ack);
    assert.equal((await client.closed)[0], 2);
    assert.match(client.stderr(), /invalid acknowledgement/);
    remote("execute('q!')");
    // Closing the host buffer after the client rejected the ack may emit an abort.
    for (const name of readdirSync(acks)) rmSync(join(acks, name));
  });

  for (const address of [undefined, `${server}-missing`]) {
    await t.test(address ? "stale host falls back locally" : "no host falls back locally", async () => {
      const client = startClient({
        NVIM: address,
        VIMINIT: "lua vim.cmd('cquit 7')",
      });
      assert.equal((await client.closed)[0], 7, client.stderr());
      assert.deepEqual(readdirSync(requests), []);
      assert.deepEqual(readdirSync(acks), []);
    });
  }

  await t.test("host loss after opened fails instead of submitting", async () => {
    const client = startClient();
    await waitFor(() => readdirSync(acks).some((name) => name.endsWith(".json")));
    host.kill();
    await hostClosed;
    assert.equal((await client.closed)[0], 2, client.stderr());
    assert.match(client.stderr(), /host disconnected/);
    assert.deepEqual(readdirSync(requests), []);
    assert.deepEqual(readdirSync(acks), []);
  });
});

test("invalid arguments fail before opening Neovim", () => {
  for (const args of [[], ["+bad", "draft.md"], ["+99999999999999999999", "draft.md"]]) {
    const result = spawnSync(process.execPath, [wrapper, ...args], { encoding: "utf8", timeout: 2000 });
    assert.equal(result.status, 2);
    assert.match(result.stderr, /Usage:/);
  }
});
