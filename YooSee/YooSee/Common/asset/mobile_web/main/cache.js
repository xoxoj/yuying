!function(){function e(){var e="./";if(window.nativePlugin&&(e="http://112.74.135.133/mobile_web/"),this.url=e,window.nativePlugin&&"android"==nativePlugin.getUserInfo().os&&window.nativePlugin.getSystemVersion()<19){var t=this.url+"css/osprey.css",i=this.url+"main/osprey.min.js";return void $("head").append('<link href="'+t+'" rel="stylesheet"><script type="text/javascript" src="'+i+'"></script>')}var o=localStorage.getItem("cache");o&&"undefined"==o&&(o=!1),this.cache=o?JSON.parse(o):!1,this.init()}e.prototype.init=function(){var e=this.cache,t=this.url+"css/osprey.css",i=this.url+"main/osprey.min.js";return e?(this.inspect(t,"css"),void this.inspect(i,"js")):(this.cache={},this.getServiceScript(t,"css"),void this.getServiceScript(i,"js"))},e.prototype.inspect=function(e,t){return this.cache[t]&&this.cache[t][e]?void this.getFileModified(e,t):void this.getServiceScript(e,t)},e.prototype.getFileModified=function(e,t){var i=new XMLHttpRequest;i.timeout=1e3,i.open("head",e,!0),i.responseType="text";var o=this;i.onerror=function(){o.noNetWorkPrompt()},i.onloadend=function(s){if(4==i.readyState&&200==i.status)var n=i.getResponseHeader("last-modified");o.cache[t].modified==n?o.getLocalFile(e,t):o.getServiceScript(e,t)},i.send(null);var i=new XMLHttpRequest;i.timeout=1e3,i.open("get",this.url+"main/osprey.min.js",!0),i.responseType="text",i.onloadend=function(e){window.data=e},i.send(null)},e.prototype.appendFile=function(e,t,i){var o=$("head");if("local"==i?osprey.global.cacheFile="cache":osprey.global.cacheFile=this.cache,"css"==t){var s=document.createElement("style"),s=$(s).html(e);o.append(s)}if("js"==t){var n=document.createElement("script");n.type="text/javascript",n=$(n).html(e),o.append(n)}},e.prototype.getServiceScript=function(e,t){var i=$.ajax(e,{context:this,timeout:1e3,dataType:"text",success:function(o){this.cache[t]={},this.cache[t].modified=i.getResponseHeader("last-modified"),this.cache[t][e]=o,this.appendFile(o,t)},error:function(e){this.noNetWorkPrompt()}})},e.prototype.getLocalFile=function(e,t){this.appendFile(this.cache[t][e],t,"local")},e.prototype.noNetWorkPrompt=function(){var e=$('<div class="text-center" style="margin-top: 15rem;"> <h1><i class="glyphicon glyphicon-eye-close" style="font-size: 6rem;color: #DD5044;"></i></h1><h4 style="color: darkgray;font-weight: bold;">很抱歉，网络不给力哦~</h4><div class="network-refresh" style="padding:10px;background-color:#eee;margin:0 auto;width:80px;">刷新 <i class="glyphicon glyphicon-refresh"></i></div></div>');e.on("click",e,this.networkRefresh.bind(this)),$("body").html(e)},e.prototype.networkRefresh=function(e){e.stopPropagation();var t=e.data;t.remove(),this.init()},new e}();