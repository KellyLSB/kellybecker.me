# KellyBecker.me

# Helpful GH Api Tools

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
