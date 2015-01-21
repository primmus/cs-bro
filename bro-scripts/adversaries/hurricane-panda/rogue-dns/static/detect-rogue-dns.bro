# Detects a Hurricane Panda tactic of using Hurricane Electric to resolve commonly accessed websites
# Alerts when a domain in the Alexa top 500 is resolved via Hurricane Electric and/or when a host connects to an IP in the DNS response
# CrowdStrike 2015
# josh.liburdi@crowdstrike.com

@load base/protocols/dns
@load base/frameworks/notice
@load base/frameworks/input

module CrowdStrike::Hurricane_Panda;

export {
  redef enum Notice::Type += {
    HE_Request,
    HE_Successful_Conn
  };
}

# Current as of 01/20/2015
# alexa.com/topsites
const alexa_table: set[string] = {
  google.com,
  facebook.com,
  youtube.com,
  yahoo.com,
  baidu.com,
  amazon.com,
  wikipedia.org,
  twitter.com,
  taobao.com,
  qq.com,
  google.co.in,
  live.com,
  sina.com.cn,
  weibo.com,
  linkedin.com,
  yahoo.co.jp,
  tmall.com,
  blogspot.com,
  ebay.com,
  hao123.com,
  google.co.jp,
  google.de,
  yandex.ru,
  bing.com,
  sohu.com,
  vk.com,
  instagram.com,
  tumblr.com,
  reddit.com,
  google.co.uk,
  pinterest.com,
  amazon.co.jp,
  wordpress.com,
  msn.com,
  imgur.com,
  google.fr,
  adcash.com,
  google.com.br,
  ask.com,
  paypal.com,
  imdb.com,
  aliexpress.com,
  xvideos.com,
  alibaba.com,
  apple.com,
  fc2.com,
  microsoft.com,
  mail.ru,
  t.co,
  google.it,
  360.cn,
  google.ru,
  amazon.de,
  google.es,
  kickass.so,
  netflix.com,
  163.com,
  go.com,
  xinhuanet.com,
  gmw.cn,
  onclickads.net,
  google.com.hk,
  craigslist.org,
  stackoverflow.com,
  xhamster.com,
  people.com.cn,
  google.ca,
  amazon.co.uk,
  naver.com,
  soso.com,
  amazon.cn,
  googleadservices.com,
  pornhub.com,
  bbc.co.uk,
  google.com.tr,
  cnn.com,
  diply.com,
  rakuten.co.jp,
  espn.go.com,
  ebay.de,
  nicovideo.jp,
  dailymotion.com,
  google.com.mx,
  adobe.com,
  cntv.cn,
  flipkart.com,
  google.pl,
  youku.com,
  google.com.au,
  alipay.com,
  ok.ru,
  blogger.com,
  huffingtonpost.com,
  dropbox.com,
  chinadaily.com.cn,
  googleusercontent.com,
  wikia.com,
  nytimes.com,
  google.co.kr,
  ebay.co.uk,
  dailymail.co.uk,
  china.com,
  livedoor.com,
  github.com,
  indiatimes.com,
  pixnet.net,
  jd.com,
  tudou.com,
  sogou.com,
  outbrain.com,
  uol.com.br,
  buzzfeed.com,
  gmail.com,
  xnxx.com,
  google.com.tw,
  blogspot.in,
  amazon.in,
  booking.com,
  google.com.eg,
  chase.com,
  ameblo.jp,
  cnet.com,
  redtube.com,
  pconline.com.cn,
  directrev.com,
  flickr.com,
  amazon.fr,
  douban.com,
  about.com,
  yelp.com,
  wordpress.org,
  dmm.co.jp,
  ettoday.net,
  walmart.com,
  globo.com,
  bankofamerica.com,
  youporn.com,
  bp.blogspot.com,
  youradexchange.com,
  vimeo.com,
  google.com.pk,
  coccoc.com,
  google.nl,
  etsy.com,
  snapdeal.com,
  naver.jp,
  deviantart.com,
  godaddy.com,
  bbc.com,
  daum.net,
  amazonaws.com,
  themeforest.net,
  bestbuy.com,
  aol.com,
  theguardian.com,
  weather.com,
  zol.com.cn,
  google.com.ar,
  adf.ly,
  amazon.it,
  livejasmin.com,
  life.com.tw,
  salesforce.com,
  google.com.sa,
  twitch.tv,
  forbes.com,
  bycontext.com,
  livejournal.com,
  soundcloud.com,
  loading-delivery1.com,
  wikihow.com,
  slideshare.net,
  wellsfargo.com,
  google.gr,
  stackexchange.com,
  jabong.com,
  google.co.id,
  google.co.za,
  leboncoin.fr,
  blogfa.com,
  feedly.com,
  indeed.com,
  ikea.com,
  quora.com,
  ups.com,
  xcar.com.cn,
  espncricinfo.com,
  target.com,
  china.com.cn,
  ziddu.com,
  theadgateway.com,
  allegro.pl,
  businessinsider.com,
  popads.net,
  w3schools.com,
  pixiv.net,
  mozilla.org,
  onet.pl,
  reference.com,
  google.com.ua,
  torrentz.eu,
  9gag.com,
  mediafire.com,
  files.wordpress.com,
  tubecup.com,
  archive.org,
  wikimedia.org,
  likes.com,
  mailchimp.com,
  tripadvisor.com,
  amazon.es,
  theladbible.com,
  goo.ne.jp,
  usps.com,
  foxnews.com,
  steampowered.com,
  ifeng.com,
  sourceforge.net,
  google.be,
  ndtv.com,
  badoo.com,
  google.co.th,
  zillow.com,
  mystart.com,
  web.de,
  google.com.vn,
  slickdeals.net,
  washingtonpost.com,
  kakaku.com,
  huanqiu.com,
  tianya.cn,
  google.ro,
  skype.com,
  dmm.com,
  ask.fm,
  comcast.net,
  telegraph.co.uk,
  americanexpress.com,
  gmx.net,
  google.com.my,
  secureserver.net,
  bet365.com,
  avg.com,
  mama.cn,
  ign.com,
  force.com,
  akamaihd.net,
  orange.fr,
  gfycat.com,
  steamcommunity.com,
  ppomppu.co.kr,
  gameforge.com,
  answers.com,
  media.tumblr.com,
  google.cn,
  softonic.com,
  google.se,
  newegg.com,
  google.com.co,
  mashable.com,
  reimageplus.com,
  doorblog.jp,
  goodreads.com,
  google.com.ng,
  rediff.com,
  ilividnewtab.com,
  groupon.com,
  stumbleupon.com,
  icicibank.com,
  google.com.sg,
  doublepimp.com,
  google.at,
  wp.pl,
  b5m.com,
  tube8.com,
  rutracker.org,
  chinatimes.com,
  fedex.com,
  abs-cbnnews.com,
  engadget.com,
  zhihu.com,
  caijing.com.cn,
  smzdm.com,
  bild.de,
  pchome.net,
  hdfcbank.com,
  quikr.com,
  rambler.ru,
  amazon.ca,
  google.pt,
  mercadolivre.com.br,
  spiegel.de,
  nfl.com,
  bleacherreport.com,
  t-online.de,
  xuite.net,
  webssearches.com,
  taboola.com,
  weebly.com,
  gizmodo.com,
  hurriyet.com.tr,
  pandora.com,
  shutterstock.com,
  wsj.com,
  gome.com.cn,
  avito.ru,
  what-character-are-you.com,
  homedepot.com,
  seznam.cz,
  youth.cn,
  pclady.com.cn,
  iqiyi.com,
  nih.gov,
  usatoday.com,
  vice.com,
  lifehacker.com,
  webmd.com,
  wix.com,
  hulu.com,
  ebay.in,
  samsung.com,
  hp.com,
  hootsuite.com,
  google.dz,
  extratorrent.cc,
  accuweather.com,
  addthis.com,
  firstmediahub.com,
  speedtest.net,
  kompas.com,
  google.ch,
  ameba.jp,
  macys.com,
  gsmarena.com,
  liveinternet.ru,
  milliyet.com.tr,
  photobucket.com,
  fiverr.com,
  hupu.com,
  39.net,
  dell.com,
  youm7.com,
  adsrvmedia.net,
  wow.com,
  4shared.com,
  microsoftonline.com,
  github.io,
  bilibili.com,
  varzesh3.com,
  retailmenot.com,
  myntra.com,
  mobile01.com,
  google.com.pe,
  google.com.bd,
  udn.com,
  capitalone.com,
  tistory.com,
  spotify.com,
  evernote.com,
  theverge.com,
  babytree.com,
  liputan6.com,
  xda-developers.com,
  att.com,
  omiga-plus.com,
  google.com.ph,
  nba.com,
  techcrunch.com,
  wordreference.com,
  google.no,
  battle.net,
  office.com,
  uploaded.net,
  reuters.com,
  libero.it,
  in.com,
  rt.com,
  disqus.com,
  google.co.hu,
  ebay.com.au,
  rbc.ru,
  google.cz,
  time.com,
  goal.com,
  google.ae,
  hstpnetwork.com,
  moz.com,
  intoday.in,
  rottentomatoes.com,
  aili.com,
  goodgamestudios.com,
  lady8844.com,
  onlinesbi.com,
  hudong.com,
  kaskus.co.id,
  twimg.com,
  stylene.net,
  teepr.com,
  zendesk.com,
  google.ie,
  gap.com,
  codecanyon.net,
  yandex.ua,
  verizonwireless.com,
  olx.in,
  okcupid.com,
  bloomberg.com,
  nordstrom.com,
  google.co.il,
  justdial.com,
  intuit.com,
  googleapis.com,
  trackingclick.net,
  ltn.com.tw,
  sahibinden.com,
  2ch.net,
  free.fr,
  so.com,
  ebay.it,
  thefreedictionary.com,
  csdn.net,
  12306.cn,
  meetup.com,
  trello.com,
  fbcdn.net,
  autohome.com.cn,
  cnzz.com,
  kinopoisk.ru,
  dsrlte.com,
  gmarket.co.kr,
  detik.com,
  staticwebdom.com,
  marca.com,
  bhaskar.com,
  chinaz.com,
  naukri.com,
  ganji.com,
  gamefaqs.com,
  kohls.com,
  eksisozluk.com,
  ero-advertising.com,
  agoda.com,
  expedia.com,
  npr.org,
  bitly.com,
  mackeeper.com,
  styletv.com.cn,
  allrecipes.com,
  repubblica.it,
  google.fi,
  exoclick.com,
  kickstarter.com,
  baomihua.com,
  beeg.com,
  sears.com,
  mbtrx.com,
  faithtap.com,
  citibank.com,
  ehow.com,
  cloudfront.net,
  tmz.com,
  blog.jp,
  hostgator.com,
  doubleclick.com,
  media1first.com,
  jmpdirect01.com,
  livedoor.biz,
  slimspots.com,
  abcnews.go.com,
  oracle.com,
  chaturbate.com,
  scribd.com,
  outlook.com,
  eyny.com,
  popcash.net,
  xe.com,
  mega.co.nz,
  ink361.com,
  gawker.com,
  sex.com,
  woot.com,
  xywy.com,
  lemonde.fr,
  asos.com,
  ci123.com,
  zippyshare.com,
  chip.de,
  elpais.com,
  putlocker.is,
  nbcnews.com,
  php.net,
  nyaa.se,
  eastday.com,
  google.az,
  list-manage.com,
  eonline.com,
  foodnetwork.com,
  google.dk,
  independent.co.uk,
  statcounter.com
} &redef;

const he_nets: set[subnet] = {
  216.218.130.2,
  216.66.1.2,
  216.66.80.18,
  216.218.132.2,
  216.218.131.2
} &redef;

# Pattern used to identify subdomains
const subdomains =  /^d?ns[0-9]*\./    |
                    /^smtp[0-9]*\./    |
                    /^mail[0-9]*\./    |
                    /^pop[0-9]*\./     |
                    /^imap[0-9]*\./    |
                    /^www[0-9]*\./     |
                    /^ftp[0-9]*\./     |
                    /^img[0-9]*\./     |
                    /^images?[0-9]*\./ |
                    /^search[0-9]*\./  |
                    /^nginx[0-9]*\./ &redef;

# Container to store IP address answers from Hurricane Electric queries
# Each entry expires 5 minutes after the last time it was written
global he_answers: set[addr] &write_expire=5min;

event DNS::log_dns(rec: DNS::Info)
{
# Do not process the event if no query exists or if the query is not being resolved by Hurricane Electric
if ( ! rec?$query ) return;
if ( rec$id$resp_h !in he_nets ) return;

# If necessary, clean the query so that it can be found in the list of Alexa domains
local query = rec$query;
if ( subdomains in query )
  query = sub(rec$query,subdomains,"");

# Check if the query is in the list of Alexa domains
# If it is, then this activity is suspicious and should be investigated
if ( query in alexa_table )
  {
  # Prepare the sub-message for the notice
  # Include the domain queried in the sub-message
  local sub_msg = fmt("Query: %s",query);

  # If the query was answered, include the answers in the sub-message
  if ( rec?$answers )
    {
    sub_msg += fmt(" %s: ", rec$total_answers > 1 ? "Answers":"Answer");

    for ( ans in rec$answers )
      {
      # If an answers value is an IP address, store it for later processing 
      if ( is_valid_ip(rec$answers[ans]) == T )
        add he_answers[to_addr(rec$answers[ans])];
      sub_msg += fmt("%s, ", rec$answers[ans]);
      }

    # Clean the sub-message.
    sub_msg = cut_tail(sub_msg,2);
    }

  # Generate the notice
  # Includes the connection flow, host intiating the lookup, domain queried, and query answers (if available)
  NOTICE([$note=HE_Request,
          $msg=fmt("%s made a suspicious DNS lookup to Hurricane Electric", rec$id$orig_h),
          $sub=sub_msg,
          $id=rec$id,
          $uid=rec$uid,
          $identifier=cat(rec$id$orig_h,rec$query)]);
  }
}

event connection_state_remove(c: connection)
{
# Check if a host connected to an IP address seen in an answer from Hurricane Electric
if ( c$id$resp_h in he_answers )
  NOTICE([$note=HE_Successful_Conn,
          $conn=c,
          $msg=fmt("%s connected to a suspicious server resolved by Hurricane Electric", c$id$orig_h),
          $identifier=cat(c$id$orig_h,c$id$resp_h)]);
}
