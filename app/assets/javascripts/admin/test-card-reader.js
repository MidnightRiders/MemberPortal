var testCardReader = function() {
  var event,
      expDate = new Date(new Date() + 60 * 1000 * 24 * 31),
      expString = expDate.getFullYear().toString().slice(-2) + String('00' + (expDate.getMonth() + 2)).slice(-2);
  var testMagneticStrip = '%B44242424242424242^LASTNAME/FIRSTNAME ^' + expString + '201000000000012345678901234?;4242424242424242=' + expString + '12345678901234?';
  for (var i = 0, len = testMagneticStrip.length; i < len; i++) {
    var code = testMagneticStrip.charCodeAt(i);
    event = new KeyboardEvent('keypress', { bubbles: true});
    Object.defineProperty(event, 'charCode', {get:function(){return this.charCodeVal;}});
    event.charCodeVal = code;
    console.log(event);
    document.body.dispatchEvent(event);
  }
};
