curl ^"http://localhost:11111/api/video/parse^" ^
  -H ^"Accept: application/json, text/plain, */*^" ^
  -H ^"Accept-Language: zh-CN,zh;q=0.9^" ^
  -H ^"Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OCwicm9sZSI6IjEiLCJkZXZpY2UiOiJwYyIsIm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AYmIuY29tIiwiaWF0IjoxNzQ4OTQ0NzM0LCJleHAiOjE3NDk1NDk1MzR9.jHSP9xU_82T7piVkR8OjHyFvILUfe6BAuAOfaXnawZI^" ^
  -H ^"Connection: keep-alive^" ^
  -H ^"Content-Type: application/json^" ^
  -H ^"Origin: http://localhost:11111^" ^
  -H ^"Referer: http://localhost:11112/bilibili^" ^
  -H ^"Sec-Fetch-Dest: empty^" ^
  -H ^"Sec-Fetch-Mode: cors^" ^
  -H ^"Sec-Fetch-Site: same-origin^" ^
  -H ^"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0^" ^
  -H ^"deviceType: pc^" ^
  -H ^"sec-ch-ua: ^\^"Microsoft Edge^\^";v=^\^"137^\^", ^\^"Chromium^\^";v=^\^"137^\^", ^\^"Not/A)Brand^\^";v=^\^"24^\^"^" ^
  -H ^"sec-ch-ua-mobile: ?0^" ^
  -H ^"sec-ch-ua-platform: ^\^"Windows^\^"^" ^
  --data-raw ^"^{^\^"url^\^":^\^"BV1Ju7pz4Eu6^\^",^\^"quality^\^":80^}^"

  {
  "url": "BV1Ju7pz4Eu6",
  "quality": 80
}

{
    "code": 200,
    "message": "视频解析成功",
    "data": {
        "bvid": "BV1Ju7pz4Eu6",
        "aid": 114597025549478,
        "title": "在\"钠\"模组后-网易又来重量级选手-我的世界杂谈",
        "description": "并不是说网易大部分充斥着劣质模组-而是想说这种模组能不能管管？有严重bug就打会让作者重做！这个视频可能有地方说的不够全面 见谅~\n小部分内容来着我的世界维基百科\nhttps://zh.minecraft.wiki/",
        "duration": 274,
        "view": 86730,
        "danmaku": 134,
        "like": 1582,
        "coin": 155,
        "share": 308,
        "reply": 540,
        "favorite": 314,
        "owner": {
            "mid": 320500029,
            "name": "大佬萌茶",
            "face": "https://i0.hdslb.com/bfs/face/caa4a2e15da0395e7afd66be26e2efcdee5236c9.jpg"
        },
        "pubdate": 1748612560,
        "pic": "http://i2.hdslb.com/bfs/archive/6a2c59ffede089592ade8250420b62ab700d255b.jpg",
        "pages": [
            {
                "cid": 30233200097,
                "page": 1,
                "from": "vupload",
                "part": "在\"钠\"模组后-网易又来重量级选手-我的世界杂谈",
                "duration": 274,
                "vid": "",
                "weblink": "",
                "dimension": {
                    "width": 2560,
                    "height": 1440,
                    "rotate": 0
                },
                "first_frame": "http://i0.hdslb.com/bfs/storyff/n250530sahs1q8zjecm51muuy5wvthd2_firsti.jpg",
                "ctime": 1748612560
            }
        ],
        "cid": 30233200097,
        "tname": "单机游戏",
        "current_viewers": 0,
        "quality": 80,
        "qualityDesc": "1080P 高清",
        "downloadUrls": {
            "video": "https://xy182x89x193x208xy.mcdn.bilivideo.cn:8082/v1/resource/30233200097-1-100050.m4s?agrr=1&build=0&buvid=&bvc=vod&bw=247565&deadline=1748951958&dl=0&e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M%3D&f=u_0_0&gen=playurlv3&mcdnid=50028572&mid=424572043&nbs=1&nettype=0&og=hw&oi=3086004994&orderid=0%2C3&os=mcdn&platform=pc&sign=82f6d1&tag=&traceid=trhJOrgyCVeuNo_0_e_N&uipk=5&uparams=e%2Cmid%2Cuipk%2Cplatform%2Ctrid%2Cgen%2Cos%2Cog%2Coi%2Cdeadline%2Ctag%2Cnbs&upsig=d655291a2d19dded06e1faf70075d73b",
            "audio": "https://xy180x97x206x143xy.mcdn.bilivideo.cn:8082/v1/resource/30233200097-1-30280.m4s?agrr=1&build=0&buvid=&bvc=vod&bw=167424&deadline=1748951958&dl=0&e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M%3D&f=u_0_0&gen=playurlv3&mcdnid=50028572&mid=424572043&nbs=1&nettype=0&og=cos&oi=3086004994&orderid=0%2C3&os=mcdn&platform=pc&sign=e1f0dd&tag=&traceid=trGaUnUizCwqBn_0_e_N&uipk=5&uparams=e%2Cuipk%2Cplatform%2Cgen%2Cog%2Ctrid%2Cdeadline%2Ctag%2Cos%2Cmid%2Coi%2Cnbs&upsig=466a51cfd7bdcaf0ccea8587eac03f99"
        },
        "videoUrl": "https://xy182x89x193x208xy.mcdn.bilivideo.cn:8082/v1/resource/30233200097-1-100050.m4s?agrr=1&build=0&buvid=&bvc=vod&bw=247565&deadline=1748951958&dl=0&e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M%3D&f=u_0_0&gen=playurlv3&mcdnid=50028572&mid=424572043&nbs=1&nettype=0&og=hw&oi=3086004994&orderid=0%2C3&os=mcdn&platform=pc&sign=82f6d1&tag=&traceid=trhJOrgyCVeuNo_0_e_N&uipk=5&uparams=e%2Cmid%2Cuipk%2Cplatform%2Ctrid%2Cgen%2Cos%2Cog%2Coi%2Cdeadline%2Ctag%2Cnbs&upsig=d655291a2d19dded06e1faf70075d73b",
        "audioUrl": "https://xy180x97x206x143xy.mcdn.bilivideo.cn:8082/v1/resource/30233200097-1-30280.m4s?agrr=1&build=0&buvid=&bvc=vod&bw=167424&deadline=1748951958&dl=0&e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M%3D&f=u_0_0&gen=playurlv3&mcdnid=50028572&mid=424572043&nbs=1&nettype=0&og=cos&oi=3086004994&orderid=0%2C3&os=mcdn&platform=pc&sign=e1f0dd&tag=&traceid=trGaUnUizCwqBn_0_e_N&uipk=5&uparams=e%2Cuipk%2Cplatform%2Cgen%2Cog%2Ctrid%2Cdeadline%2Ctag%2Cos%2Cmid%2Coi%2Cnbs&upsig=466a51cfd7bdcaf0ccea8587eac03f99",
        "fileSize": null
    }
}