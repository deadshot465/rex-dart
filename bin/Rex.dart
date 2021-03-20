import 'dart:math';

import 'package:dotenv/dotenv.dart' show load, env;
import 'package:nyxx/nyxx.dart';

const RANDOM_RESPONSES = ['Hello there' 'Good evening' 'Good morning' "G'day" 'Hi'];

void main(List<String> arguments) {
  load();
  final token = env['TOKEN'];
  final client = Nyxx(token, GatewayIntents.guildMessages);

  client.onReady.listen((event) {
    client.setPresence(PresenceBuilder.of(status: UserStatus.online, game: Activity.of('Xenoblade Chronicles 2')));
  });

  client.onSelfMention.listen((event) async {
    final mention = '<@${event.message.author.id.id}>';
    final rng = Random();
    final randomResponse = RANDOM_RESPONSES[rng.nextInt(RANDOM_RESPONSES.length)];
    final channel = await event.message.channel.getOrDownload();
    await channel.sendMessage(content: '$randomResponse, $mention!');
  });

  client.onMessageReceived.listen((event) async {
    if (event.message.content == 'r?ping') {
      final startTime = DateTime.now();
      final channel = await event.message.channel.getOrDownload();
      final message = await channel.sendMessage(content: '\uD83C\uDFD3 Pinging...');
      final diff = DateTime.now().difference(startTime).inMilliseconds;
      await message?.edit(content: '\uD83C\uDFD3 Pong!\nLatency is: ${diff}ms.');
    }

    if (event.message.content == 'r?about') {
      final iconUrl = client.app.iconUrl();
      final embed = EmbedBuilder()
          ..addAuthor((author) {
            author.iconUrl = iconUrl;
            author.name = 'Rex from Xenoblade Chronicles 2';
          })
          ..addFooter((footer) {
            footer.text = 'Rex Bot: Release 0.2 | 2021-03-20';
          });
      embed.color = DiscordColor.fromHexString('#37FEAB');
      embed.thumbnailUrl = 'https://cdn.discordapp.com/emojis/236895119972892672.png';
      embed.description = 'Rex in the Church of Minamoto Kou.\nRex was inspired by the game Xenoblade Chronicles 2 on Nintendo Switch.\nRex version 0.2 was made and developed by:\n**Tetsuki Syu#1250, Kirito#9286**\nWritten with:\n[Dart](https://dart.dev/) and [Nyxx](https://github.com/l7ssha/nyxx) library.';
      final channel = await event.message.channel.getOrDownload();
      await channel.sendMessage(embed: embed);
    }
  });
}
