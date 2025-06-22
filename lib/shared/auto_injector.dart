import 'package:auto_injector/auto_injector.dart';
import 'package:webplayer_embedded/webplayer_embedded.dart';

final autoInjector = AutoInjector();

void registerAutoInjector() {
  autoInjector.addSingleton(WebPlayerEmbedded.new);
  autoInjector.commit();
}
