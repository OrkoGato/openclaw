import { expect, it } from "vitest";
import { startGatewayRestartProvider } from "./gateway-restart-provider.js";
import { withinTest } from "./promise.js";

it("holds plugin cleanup while unrelated provider work can finish", async ({
  signal,
  onTestFinished,
}) => {
  const provider = await startGatewayRestartProvider(signal);
  onTestFinished(() => provider.close());
  let cleanupFinished = false;
  const cleanup = fetch(provider.pluginStopUrl, { method: "POST", signal }).then((response) => {
    cleanupFinished = true;
    return response;
  });
  void cleanup.catch(() => {});
  await withinTest(provider.pluginStopStarted, signal);

  const reply = await fetch(`${provider.baseUrl}/responses`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ model: "fixture", input: [], stream: false }),
    signal,
  });
  expect(reply.ok).toBe(true);
  await reply.json();
  expect(cleanupFinished).toBe(false);

  provider.releasePluginStop();
  expect((await cleanup).status).toBe(204);
});
