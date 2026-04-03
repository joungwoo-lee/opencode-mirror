import type { Argv } from "yargs"
import { Instance } from "../../project/instance"
import { Provider } from "../../provider/provider"
import { ProviderID } from "../../provider/schema"
import { ModelsDev } from "../../provider/models"
import { cmd } from "./cmd"
import { UI } from "../ui"
import { EOL } from "os"

export const ModelsCommand = cmd({
  command: "models [provider]",
  describe: "list all available models",
  builder: (yargs: Argv) => {
    return yargs
      .positional("provider", {
        describe: "provider ID to filter models by",
        type: "string",
        array: false,
      })
      .option("verbose", {
        describe: "use more verbose model output (includes metadata like costs)",
        type: "boolean",
      })
      .option("refresh", {
        describe: "refresh the models cache from models.dev",
        type: "boolean",
      })
      .option("json", {
        describe: "output the models in opencode.json format",
        type: "boolean",
      })
  },
  handler: async (args) => {
    if (args.refresh) {
      await ModelsDev.refresh(true)
      UI.println(UI.Style.TEXT_SUCCESS_BOLD + "Models cache refreshed" + UI.Style.TEXT_NORMAL)
    }

    await Instance.provide({
      directory: process.cwd(),
      async fn() {
        const providers = await Provider.list()

        if (args.json) {
          const result: Record<string, any> = { provider: {} }

          if (args.provider) {
            const provider = providers[ProviderID.make(args.provider)]
            if (!provider) {
              UI.error(`Provider not found: ${args.provider}`)
              return
            }
            result.provider[args.provider] = { models: provider.models }
          } else {
            const providerIDs = Object.keys(providers).sort((a, b) => {
              const aIsOpencode = a.startsWith("opencode")
              const bIsOpencode = b.startsWith("opencode")
              if (aIsOpencode && !bIsOpencode) return -1
              if (!aIsOpencode && bIsOpencode) return 1
              return a.localeCompare(b)
            })

            for (const providerID of providerIDs) {
              result.provider[providerID] = { models: providers[ProviderID.make(providerID)].models }
            }
          }

          process.stdout.write(JSON.stringify(result, null, 2))
          process.stdout.write(EOL)
          return
        }

        function printModels(providerID: ProviderID, verbose?: boolean) {
          const provider = providers[providerID]
          const sortedModels = Object.entries(provider.models).sort(([a], [b]) => a.localeCompare(b))
          for (const [modelID, model] of sortedModels) {
            process.stdout.write(`${providerID}/${modelID}`)
            process.stdout.write(EOL)
            if (verbose) {
              process.stdout.write(JSON.stringify(model, null, 2))
              process.stdout.write(EOL)
            }
          }
        }

        if (args.provider) {
          const provider = providers[ProviderID.make(args.provider)]
          if (!provider) {
            UI.error(`Provider not found: ${args.provider}`)
            return
          }

          printModels(ProviderID.make(args.provider), args.verbose)
          return
        }

        const providerIDs = Object.keys(providers).sort((a, b) => {
          const aIsOpencode = a.startsWith("opencode")
          const bIsOpencode = b.startsWith("opencode")
          if (aIsOpencode && !bIsOpencode) return -1
          if (!aIsOpencode && bIsOpencode) return 1
          return a.localeCompare(b)
        })

        for (const providerID of providerIDs) {
          printModels(ProviderID.make(providerID), args.verbose)
        }
      },
    })
  },
})
