import type { StorybookConfig } from "@storybook/react-vite"

const config: StorybookConfig = {
  stories: ["../src/**/*.stories.@(js|jsx|ts|tsx)"],
  addons: ["@storybook/addon-links"],
  framework: {
    name: "@storybook/react-vite",
    options: {},
  },
  staticDirs: ["../src/stories/static"],
  viteFinal: (config) => ({
    ...config,
    optimizeDeps: {
      ...config.optimizeDeps,
      include: [...(config.optimizeDeps?.include ?? []), "@emotion/react > hoist-non-react-statics"],
    },
  }),
}

export default config
