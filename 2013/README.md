# KellyBecker.me

# Helpful Stuff

## Ubuntu Server Display Out of Range

http://ubuntuforums.org/showthread.php?t=1751950&p=10868071#post10868071

## Ansi Color Code Regex

`\x1b\[[0-9]*(;[0-9]*|)m`

## Github oAuth Deploy Keys

You can always generate an oAuth token with

```sh
$ curl -u 'username' -d '{"scopes":["repo"],"note":"Help example"}' \
    https://api.github.com/authorizations
```

as documented on https://help.github.com/articles/creating-an-oauth-token-for-command-line-use then pull with

```sh
$ git clone https://<key>:x-oauth-basic@github.com/<user>/<repo>
```
