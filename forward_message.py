#!/usr/bin/env python3
import os
import sys
import time
# Case insensitive match doesn't work for Cyrillic in events.NewMessage(pattern='(?i)[А-Я]')
# https://docs.telethon.dev/en/stable/modules/events.html#telethon.events.newmessage.NewMessage 
# as a temporary solution I use 're'
import re

from telethon import TelegramClient, events


def get_env(name, message, cast=str):
    if name in os.environ:
        return os.environ[name]
    while True:
        value = input(message)
        try:
            return cast(value)
        except ValueError as e:
            print(e, file=sys.stderr)
            time.sleep(1)


session = os.environ.get('TG_SESSION', 'session')
api_id = get_env('TG_API_ID', 'Enter your API ID: ', int)
api_hash = get_env('TG_API_HASH', 'Enter your API hash: ')

client = TelegramClient('session', api_id, api_hash)

chat_id = ''
chanels = []
re_list = []
generic_re = re.compile('|'.join(re_list))


@client.on(events.NewMessage)
async def handler_mex(event):
    if event.chat_id in chanels:
        if generic_re.findall(event.text):
            await client.forward_messages(chat_id, event.message)
            await client.send_message(chat_id, f'Message found:\n{event.text}\n\nChannel: {event.chat.title}\nName: @{event.chat.username}\nID: {event.chat_id}')


client.start()
client.run_until_disconnected()