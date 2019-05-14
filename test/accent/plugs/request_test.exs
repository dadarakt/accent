defmodule Accent.Plug.RequestTest do
  use ExUnit.Case
  use Plug.Test

  @opts Accent.Plug.Request.init([])

  describe "init/1" do
    test "sets the \"transformer\" option to the value passed in" do
      assert Accent.Plug.Request.init(%{transformer: Accent.Transformer.CamelCase}) ==
               %{transformer: Accent.Transformer.CamelCase}
    end

    test "defaults the \"transformer\" option to Accent.Transformer.SnakeCase" do
      assert Accent.Plug.Request.init(%{}) == %{transformer: Accent.Transformer.SnakeCase}
    end
  end

  describe "call/2" do
    test "converts keys to snake_case by default" do
      conn =
        conn(:post, "/", %{"hello_world" => "value"})
        |> Accent.Plug.Request.call(@opts)

      assert conn.params == %{"hello_world" => "value"}
    end

    test "converts keys using provided transformer" do
      conn =
        conn(:post, "/", %{"hello_world" => "value"})
        |> Accent.Plug.Request.call(
          Accent.Plug.Request.init(transformer: Accent.Transformer.CamelCase)
        )

      assert conn.params == %{"helloWorld" => "value"}
    end

    test "properly handles POST requests" do
      conn =
        conn(:post, "/", "{\"helloWorld\": \"value\"}")
        |> put_req_header("content-type", "application/json")
        |> Plug.Parsers.call(Plug.Parsers.init(parsers: [:json], json_decoder: Poison))
        |> Accent.Plug.Request.call(@opts)

      assert conn.params == %{"hello_world" => "value"}
    end

    test "properly handles GET requests" do
      conn =
        conn(:get, "/?helloWorld=value")
        |> put_req_header("content-type", "application/json")
        |> Plug.Parsers.call(Plug.Parsers.init(parsers: [:json], json_decoder: Poison))
        |> Accent.Plug.Request.call(@opts)

      assert conn.params == %{"hello_world" => "value"}
    end
  end
end
