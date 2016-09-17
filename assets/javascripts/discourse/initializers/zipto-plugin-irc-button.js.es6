import { on } from 'ember-addons/ember-computed-decorators';

export default {
  name: 'zipto-irc-button',
  initialize(container) {
    const MainButtons = container.lookupFactory('view:topic-footer-main-buttons');
    const siteSettings = container.lookup('site-settings:main');
    const ButtonView = container.lookupFactory('view:button');
    const HomeButton = ButtonView.extend({
      classNames: ['zipto-irc-button'],
      text: siteSettings.zipto_home_button_title,
      title: siteSettings.zipto_home_button_description,
      click() {
        window.open(siteSettings.zipto_home_button_url, '_parent');
      }
    });

    MainButtons.reopen({
      @on('additionalButtons')
      addHomeButton(){
        this.attachViewClass(HomeButton);
      }

    });
  }
}
