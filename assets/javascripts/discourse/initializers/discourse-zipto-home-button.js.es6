export default {
  name: 'zipto-home-button',
  initialize(container) {
    const siteSettings = container.lookup('site-settings:main');
    const TopicFooterButtonsComponent = container.lookupFactory('component:topic-footer-buttons');

    TopicFooterButtonsComponent.reopen({
      actions: {
        clickButton() {
          window.open(siteSettings.zipto_home_button_url, '_self');
        }
      }
    });
  }
}
