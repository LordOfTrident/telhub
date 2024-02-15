<a name="readme-top"></a>
<div align="center">
	<a href="./LICENSE">
		<img alt="License" src="https://img.shields.io/badge/license-GPL v3-e8415e?style=for-the-badge">
	</a>
	<a href="https://github.com/LordOfTrident/telhub/graphs/contributors">
		<img alt="Contributors" src="https://img.shields.io/github/contributors/LordOfTrident/telhub?style=for-the-badge&color=f36a3b">
	</a>
	<a href="https://github.com/LordOfTrident/telhub/stargazers">
		<img alt="Stars" src="https://img.shields.io/github/stars/LordOfTrident/telhub?style=for-the-badge&color=efb300">
	</a>
	<a href="https://github.com/LordOfTrident/telhub/issues">
		<img alt="Issues" src="https://img.shields.io/github/issues/LordOfTrident/telhub?style=for-the-badge&color=0fae5e">
	</a>
	<a href="https://github.com/LordOfTrident/telhub/pulls">
		<img alt="Pull requests" src="https://img.shields.io/github/issues-pr/LordOfTrident/telhub?style=for-the-badge&color=4f79e4">
	</a>
	<br><br><br>
	<img src="./res/logo.png" width="350px">
	<h1 align="center">Telhub</h1>
	<p align="center">💬 A telnet chat server in Elixir 🧪</p>
	<p align="center">
		<a href="#demo">View Demo</a>
		·
		<a href="./todo.md">View TODO</a>
		·
		<a href="https://github.com/LordOfTrident/telhub/issues">Report Bug</a>
		·
		<a href="https://github.com/LordOfTrident/telhub/issues">Request Feature</a>
	</p>
	<br>
</div>

<details>
	<summary>Table of contents</summary>
	<ul>
		<li><a href="#introduction">Introduction</a></li>
		<li><a href="#demo">Demo</a></li>
		<li>
			<a href="#quickstart">Quickstart</a>
			<ul>
				<li><a href="#server">Server</a></li>
				<li><a href="#client">Client</a></li>
			</ul>
		</li>
		<li><a href="#bugs">Bugs</a></li>
	</ul>
</details>

## Introduction
A telnet chat server made in [Elixir](https://elixir-lang.org/). Built on top of my first server
app, [Telnexir](https://github.com/lordoftrident/telnexir).

## Demo
<p align="center">
	<img src="./res/telhub.gif" width="80%">
</p>

## Quickstart
### Server
```sh
$ git clone https://github.com/LordOfTrident/telhub
$ cd telhub
$ mix run --no-halt -- [PORT] [PASSWORD]
```

`[PASSWORD]` is an optional server password.

> [!NOTE]\
> If you dont know what to pick for `[PORT]`, you can omit it. Default is `4040`.

### Client
```sh
$ telnet <IP> <PORT>
```

> [!NOTE]\
> If you are connecting from the same computer the server is running on, put `localhost` instead of `<IP>`.

## Bugs
If you find any bugs, please, [create an issue and report them](https://github.com/LordOfTrident/telhub/issues).

<br>
<h1></h1>
<br>

<div align="center">
	<a href="https://elixir-lang.org/">
		<img alt="Elixir" src="https://img.shields.io/badge/Elixir-6d2891?style=for-the-badge&logo=elixir&logoColor=white">
	</a>
	<a href="https://en.wikipedia.org/wiki/Telnet">
		<img alt="Telnet" src="https://img.shields.io/badge/Telnet-3c424e?style=for-the-badge&logoColor=white">
	</a>
	<p align="center">Made with ❤️ love</p>
</div>

<p align="right">(<a href="#readme-top">Back to top</a>)</p>
