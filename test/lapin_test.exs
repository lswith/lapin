defmodule LapinTest do
  use ExUnit.Case
  doctest Lapin

  setup_all do
    exchange = "test_exchange"
    queue = "test_queue"

    %{
      exchange: exchange,
      queue: queue,
      message: "",
      producer: [
        module: LapinTest.HelloWorld,
        virtual_host: "/",
        channels: [
          [
            role: :producer,
            exchange: exchange,
            queue: queue
          ]
        ]
      ],
      consumer: [
        module: LapinTest.HelloWorld,
        virtual_host: "/",
        channels: [
          [
            role: :consumer,
            exchange: exchange,
            queue: queue
          ]
        ]
      ],
      passive: [
        module: LapinTest.HelloWorld,
        virtual_host: "/",
        channels: [
          [
            role: :passive,
            exchange: exchange,
            queue: queue
          ],
          [
            role: :passive,
            exchange: exchange,
            queue: queue
          ]
        ]
      ],
      bad_producer: [
        module: LapinTest.HelloWorld,
        host: "nohosthere",
        port: 9999,
        username: "thisisnotthedefault",
        password: "nopass",
        virtual_host: "/",
        channels: [
          [
            role: :producer,
            exchange: exchange,
            queue: queue
          ]
        ]
      ]
    }
  end

  test "hello_world_producer_can_publish", ctx do
    {:ok, producer} = Lapin.Connection.start_link(ctx.producer)
    :ok = Lapin.Connection.publish(producer, ctx.exchange, "", ctx.message)
    :ok = Lapin.Connection.close(producer)
  end

  test "hello_world_consumer_cant_publish", ctx do
    {:ok, consumer} = Lapin.Connection.start_link(ctx.consumer)
    {:error, _} = Lapin.Connection.publish(consumer, ctx.exchange, "", ctx.message)
    :ok = Lapin.Connection.close(consumer)
  end

  test "hello_world_passive_cant_publish", ctx do
    {:ok, passive} = Lapin.Connection.start_link(ctx.passive)
    {:error, _} = Lapin.Connection.publish(passive, ctx.exchange, "", ctx.message)
    :ok = Lapin.Connection.close(passive)
  end

  test "that the startup should stop trying to connect to a non-existent host", ctx do
    assert_raise BadConnectionException, fn ->
      {:ok, bad_host} = Lapin.Connection.start_link(ctx.bad_producer)
    end
  end
end
