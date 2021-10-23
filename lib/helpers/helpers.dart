class Helpers {
  static String truncateIfOver(String str, int charLimit) {
    if(str.length > charLimit) {
      return str.substring(0,charLimit) + '...';
    }
    return str;
  }
}