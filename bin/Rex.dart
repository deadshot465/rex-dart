import 'dart:async';
import 'dart:math';

import 'package:dotenv/dotenv.dart' show load, env;
import 'package:nyxx/nyxx.dart';
import 'package:owoify_dart/owoify_dart.dart';

const RANDOM_RESPONSES = ['やほー', 'こんばんは', 'おはよう', 'こんにちは', 'ご機嫌よう', 'よろしくね', 'なに'];
const ACTIVITIES = ['Nintendo Switch', 'ゼノブレイド2', 'PlayStation 5', 'Xbox Series X'];

void main(List<String> arguments) {
  load();
  final token = env['TOKEN'];
  final client = Nyxx(token, GatewayIntents.guildMessages | GatewayIntents.allUnprivileged);
  final rng = Random();
  var clientId = 0;
  var clientMention = '';

  Future.doWhile(() async {
    await Future.delayed(Duration(minutes: 20));
    final activity = Activity.of(ACTIVITIES[rng.nextInt(ACTIVITIES.length)]);
    try {
      client.setPresence(PresenceBuilder.of(status: UserStatus.online, game: activity));
    } catch (e) {
      print(e.toString());
    }
    return true;
  });

  client.onReady.listen((event) {
    final activity = Activity.of(ACTIVITIES[rng.nextInt(ACTIVITIES.length)]);
    client.setPresence(PresenceBuilder.of(status: UserStatus.online, game: activity));
    clientId = client.self.id.id;
    clientMention = '<@!$clientId>';
  });

  client.onSelfMention.listen((event) async {
    final author = event.message.author as User;
    final randomResponse = RANDOM_RESPONSES[rng.nextInt(RANDOM_RESPONSES.length)];
    final channel = await event.message.channel.getOrDownload();
    await channel.sendMessage(content: '$randomResponse、${author.mention}!');
  });

  client.onMessageReceived.listen((event) async {
    if (event.message.content == 'r?ping') {
      final startTime = DateTime.now();
      final channel = await event.message.channel.getOrDownload();
      final message = await channel.sendMessage(content: '\uD83C\uDFD3 ピング中……');
      final diff = DateTime.now().difference(startTime).inMilliseconds;
      await message?.edit(content: '\uD83C\uDFD3 ポン！\nレイテンシ：${diff}ミリ秒。');
    }

    if (event.message.content == 'r?about') {
      final iconUrl = client.app.iconUrl();
      final embed = EmbedBuilder()
          ..addAuthor((author) {
            author.iconUrl = iconUrl;
            author.name = 'ゼノブレイド2のレックス';
          })
          ..addFooter((footer) {
            footer.text = 'レックスボット：リリース 0.3 | 2021-03-26';
          });
      embed.color = DiscordColor.fromHexString('#37FEAB');
      embed.thumbnailUrl = 'https://cdn.discordapp.com/emojis/236895119972892672.png';
      embed.description = 'The Land of Cute Boisのレックス。\nレックスは[Nintendo Switch](https://www.nintendo.co.jp/hardware/switch/)ゲーム「[ゼノブレイド2](https://www.nintendo.co.jp/switch/adena/index.html)」の主人公から発想して、レックスの真似をするボットです。\nレックスバージョン0.2の開発者：\n**Tetsuki Syu#1250、Kirito#9286**\n制作言語・フレームワーク：\n[Dart](https://dart.dev/)と[Nyxx](https://github.com/l7ssha/nyxx)ライブラリ。';
      final channel = await event.message.channel.getOrDownload();
      await channel.sendMessage(embed: embed);
    }

    if (event.message.content.startsWith('r?owoify')) {
      final cmdLength = 'r?owoify'.length + 1;
      final content = event.message.content.substring(cmdLength);
      final channel = await event.message.channel.getOrDownload();
      await channel.sendMessage(content: Owoifier.owoify(content, level: OwoifyLevel.Uvu));
    }
  });
}
