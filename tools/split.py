import argparse
import os
import re


def get_file_name(path: str):
    idx = path.rfind("/")
    return path[idx+1:]


def process(filename: str, output_dir: str, student: bool):
    with open(filename, "r") as f:
        contents = iter(f.readlines())
    
    curr_line = next(contents)
    challenges_found = False
    challenges = []
    os.makedirs(output_dir, exist_ok=True)

    index_file = f"{output_dir}/README.md" if student else f"{output_dir}/solutions.md"
    challenges_header = "## Challenges" if student else "## Coach's Guides"
    with open(index_file, "w") as f:
        while not challenges_found:
            if curr_line.startswith(challenges_header):
                challenges_found = True
            else:
                f.write(curr_line)
                curr_line = next(contents)
        first_challenge_found = False
        while not first_challenge_found:
            if curr_line.startswith("## Challenge "):
                first_challenge_found = True
            else: 
                matches = re.match(r"- Challenge (\d+): (.+)$", curr_line)
                if matches:
                    prefix = f"challenge-" if student else "solution-" 
                    challenge_no = int(matches.group(1))
                    challenge_file = f"{prefix}{challenge_no:02d}.md"
                    challenges.append(f"{output_dir}/{challenge_file}")
                    f.write(f"- Challenge {challenge_no}: **[{matches.group(2)}]({challenge_file})**\n")
                else:
                    f.write(curr_line)
                curr_line = next(contents)
        home_file = "README.md" if student else "solutions.md"
        for idx, challenge in enumerate(challenges):
            with open(challenge, "w") as f:
                f.write(f"{curr_line[1:]}\n")  # ## Challenge X: becoming # Challenge X
                # navigation
                prv = get_file_name(challenges[idx - 1]) if idx > 0 else None
                nxt = get_file_name(challenges[idx + 1]) if idx < (len(challenges) - 1) else None
                if prv:
                    f.write(f"[< Previous Challenge]({prv}) - ")
                f.write(f"**[Home]({home_file})**")
                if nxt:
                    f.write(f" - [Next Challenge >]({nxt})")
                f.write("\n")
                curr_line = next(contents)
                next_challenge_found = False
                while curr_line is not None and not next_challenge_found:
                    if curr_line.startswith("## Challenge "):
                        next_challenge_found = True
                        break
                    elif curr_line.startswith("#"):
                        f.write(curr_line[1:])
                    else:
                        f.write(curr_line)
                    curr_line = next(contents, None)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", default="outputs")
    parser.add_argument("filename")
    args = parser.parse_args()

    process(args.filename, args.output_dir, True)
