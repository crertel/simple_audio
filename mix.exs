defmodule SimpleAudio.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_audio,
      version: "0.1.0",
      elixir: "~> 1.7",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:zigler, "~> 0.9.1", runtime: false}
    ]
  end
end
