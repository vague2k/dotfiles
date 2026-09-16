import { Plugin } from "@opencode/plugin";

const RECENT_MESSAGE_LIMIT = 10;
const MAX_MESSAGE_LENGTH = 500;

export default Plugin.define({
  id: "btw",
  async setup(ctx) {
    await ctx.command.transform((editor) => {
      editor.add({
        name: "btw",
        description: "Ask a side question without interrupting your main task",
        async execute({ sessionID, prompt, delivery }) {
          const context = await recentContext(ctx, sessionID);
          await ctx.session.prompt({
            ...prompt,
            sessionID,
            text: `${context}\n\n${prompt.text}`,
            delivery,
          });
        },
      });
    });
  },
});

async function recentContext(ctx: Plugin.Context, sessionID: string) {
  const messages = (await ctx.session.context({ sessionID })).slice(
    -RECENT_MESSAGE_LIMIT,
  );
  const lines = [
    'You are answering a quick "by the way" side question. Answer concisely (under 200 words). Do NOT make any code changes or edit files.',
    "",
    "## Recent conversation context for reference",
  ];

  for (const message of messages) {
    if (message.type === "user") {
      lines.push(`[user]: ${truncate(message.text)}`);
      continue;
    }

    if (message.type === "assistant") {
      const text = message.content
        .filter((part) => part.type === "text")
        .map((part) => part.text)
        .join("\n");
      if (text) lines.push(`[assistant]: ${truncate(text)}`);
    }
  }

  return lines.join("\n");
}

function truncate(text: string) {
  if (text.length <= MAX_MESSAGE_LENGTH) return text;
  return `${text.slice(0, MAX_MESSAGE_LENGTH)}...`;
}
