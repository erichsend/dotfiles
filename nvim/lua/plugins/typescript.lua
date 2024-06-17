return {

  { "haydenmeade/neotest-jest" },

  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "./node_modules/.bin/jest --passWithNoTests",
          jestConfigFile = function()
            local test_type = vim.api.nvim_buf_get_name(0):match("%.(%w+).spec")
            if test_type and test_type ~= "unit" then
              return "jest.config." .. test_type .. ".js"
            else
              return "jest.config.js"
            end
          end,
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {
          keys = {
            {
              "<leader>tya",
              function()
                require("neotest").run.run({
                  jestCommand = "./node_modules/.bin/jest --passWithNoTests",
                  jestConfigFile = "jest.config.js",
                  suite = true,
                  cwd = vim.fn.getcwd(),
                })
              end,
              desc = "test with jest",
            },
            {
              "<leader>tyn",
              function()
                require("neotest").run.run({
                  jestCommand = "yarn test:integration",
                  jestConfigFile = "jest.config.js",
                  suite = false,
                  cwd = vim.fn.getcwd(),
                })
              end,
              desc = "test with yarn",
            },
          },
        },
      },
      settings = {},
      setup = {
        eslint = function()
          require("lazyvim.util").lsp.on_attach(function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
  },
}
