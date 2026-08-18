#!/usr/bin/env python3
"""Test client for querying the Cymbal Retail Agent locally or on Agent Runtime."""

import argparse
import sys
import os

def test_local(prompt: str):
    """Test the agent in-process using ADK."""
    print(f"=== Testing Local Agent ===")
    print(f"User Query: {prompt}\n")
    try:
        from app.agent import root_agent
        from google.adk.runners import Runner
        from google.adk.sessions import InMemorySessionService
        import asyncio

        async def run_query():
            session_service = InMemorySessionService()
            runner = Runner(agent=root_agent, session_service=session_service)
            session = await session_service.create_session()
            events = []
            async for event in runner.run_stream(session_id=session.id, message=prompt):
                if event.get("content"):
                    print(event["content"], end="", flush=True)
                events.append(event)
            print("\n")

        asyncio.run(run_query())
    except Exception as e:
        print(f"Local test failed: {e}", file=sys.stderr)
        raise

def test_agent_runtime(resource_name: str, location: str, prompt: str):
    """Test the deployed agent on Agent Runtime using Vertex AI SDK."""
    print(f"=== Testing Deployed Agent Runtime ===")
    print(f"Resource: {resource_name}")
    print(f"Location: {location}")
    print(f"User Query: {prompt}\n")
    try:
        import vertexai
        import asyncio

        client = vertexai.Client(location=location)
        agent = client.agent_engines.get(name=resource_name)

        async def run_remote():
            print("Response: ", end="", flush=True)
            async for event in agent.async_stream_query(message=prompt, user_id="test-user"):
                # Handle text chunks in streaming events
                if hasattr(event, "text") and event.text:
                    print(event.text, end="", flush=True)
                elif isinstance(event, dict) and "text" in event:
                    print(event["text"], end="", flush=True)
                else:
                    print(str(event), end="", flush=True)
            print("\n")

        asyncio.run(run_remote())
    except Exception as e:
        print(f"Agent Runtime query failed: {e}", file=sys.stderr)
        raise

def main():
    parser = argparse.ArgumentParser(description="Test Cymbal Retail ADK Agent")
    parser.add_argument("--mode", choices=["local", "remote"], default="local", help="Execution mode")
    parser.add_argument("--resource-name", help="Agent Runtime Reasoning Engine resource name (for remote mode)")
    parser.add_argument("--location", default="us-central1", help="Google Cloud location")
    parser.add_argument("--prompt", default="What is the status of my order ORD-1001?", help="Prompt to send")

    args = parser.parse_args()

    if args.mode == "local":
        test_local(args.prompt)
    else:
        if not args.resource_name:
            print("Error: --resource-name is required for remote mode.", file=sys.stderr)
            sys.exit(1)
        test_agent_runtime(args.resource_name, args.location, args.prompt)

if __name__ == "__main__":
    main()
