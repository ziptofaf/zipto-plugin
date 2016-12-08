export default {
  name: 'zipto-home-button',
  initialize(container) {
    const siteSettings = container.lookup('site-settings:main');
    const TopicFooterButtonsComponent = container.lookupFactory('component:topic-footer-buttons');

    TopicFooterButtonsComponent.reopen({
      customButtonLabel: siteSettings.zipto_home_button_title,
      customButtonTitle: siteSettings.zipto_home_button_description,
      actions: {
        clickButton() {
          window.open(siteSettings.zipto_home_button_url, '_blank');
        }
      }
    });

  }
}
