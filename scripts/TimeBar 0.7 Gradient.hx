import flixel.ui.FlxBar;

var grad:FlxBar;
var useNewGroup:Bool;

function onCreatePost() {
    grad = new FlxBar(game.timeBar.bg.x + 4, game.timeBar.bg.y + 4, null, Std.int(game.timeBar.bg.width - 8), Std.int(game.timeBar.bg.height - 8), game,'songPercent', 0, 1);
    grad.scrollFactor.set();
    grad.numDivisions = 800;
    grad.alpha = 1;
    grad.visible = true;
    grad.cameras = [game.camHUD];
    useNewGroup = (game.members.indexOf(game.timeBar) == -1);
    if (useNewGroup) {
        game.uiGroup.add(grad);
    } else {
        game.add(grad);
    }

    //debugPrint(useNewGroup,"Group");
    changeGradientBar(getVar("mirror"));
    setTimeBarOrders();
}

function onUpdatePost() {
    grad.alpha = game.timeBar.alpha;
    grad.visible = game.timeBar.visible;
}
function onEvent(name,val1,val2) {
    if (name == "Refresh NewBar") {
        changeGradientBar(val1);
    }
}
function changeGradientBar(mirror:String) {
    var bfArray = game.boyfriend.healthColorArray;
    var dadArray = game.dad.healthColorArray;
    var bfColor = FlxColor.fromRGB(bfArray[0],bfArray[1],bfArray[2]);
    var dadColor = FlxColor.fromRGB(dadArray[0],dadArray[1],dadArray[2]);
    if (mirror == "true") {
        grad.createGradientBar([0x0], [dadColor,bfColor]);
    } else if (mirror == "false") {
        grad.createGradientBar([0x0], [bfColor,dadColor]);
    } else {
        grad.createGradientBar([0x0], [bfColor,dadColor]);
        debugPrint("mirrorBar IS NULL!!!");
    }
    
}
function setTimeBarOrders() {
    var zorder = getOrder(game.timeBar);
    setOrder(grad,zorder+1);
    setOrder(game.timeTxt,zorder+2);

    var hp = game.healthBar;
    hp.remove(hp.bg);
    hp.insert(0,hp.bg);
    hp.regenerateClips();
}
function getOrder(x) {
    var index = 0;
    if (useNewGroup) {
        index = game.uiGroup.members.indexOf(x); 
    } else {
        index = game.members.indexOf(x); 
    }
   if (index == -1) {
    debugPrint("INDEX IS -1!!!");
   }
   return index;
}
function onDestroy(){
    debugPrint("Destroying!!!");
}
function setOrder(item,spot) {
    if(item != null) {
        if (useNewGroup) {
            game.uiGroup.remove(item, true);
            game.uiGroup.insert(spot,item);
        } else {
            game.remove(item, true);
            game.insert(spot,item);
        }
         return;
     }
     debugPrint("Haxe ORDER: Object " + item + " doesn't exist!"); 
 }
