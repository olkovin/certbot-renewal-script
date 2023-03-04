The script which was created by combining ChatGPT skills and my willnes to fix anoying problem :)
Enjoy)

# Automatic SSL Certificate Creation/Renewal Script

The script was created by combining mine and ChatGPT skills and willnes to fix the anoying problem :) 

This script automates the process of creating or renewing SSL certificates using the Let's Encrypt certificate authority, with DNS validation using Amazon Route53.

## Requirements

- Bash (v4+ recommended)
- Certbot (v1.1.0+ recommended)
- Amazon Web Services CLI (v2+ recommended)

## Configuration

Before running the script, you'll need to configure the following variables in the `config_k2o_cas.conf` file:

- `email`: the email address to use for Let's Encrypt registration and renewal notifications
- `telegram_bot_token`: the token of the Telegram bot that will send notifications
- `telegram_chat_id`: the ID of the Telegram chat to which notifications will be sent

You'll also need to create a file called `config_k2o_cas_domains_list.conf` in the same directory as the script, which should contain a list of the domains for which you want to create or renew SSL certificates, one domain per line.

Note that you'll also need to manually configure and test the AWS Route53 plugin for Certbot before running this script. You can find more information on how to do this in the Certbot documentation.

## Usage

To use the script, simply run the following command:

```bash
./ssl-cert-renewal.sh
```

## Automation

To make the script runs aautomatically, simply use the crontab.

For example, to run the script every 8 hours, add the following line to your crontab file:

```bash
0 */8 * * * /path/to/ssl-cert-renewal.sh
```
