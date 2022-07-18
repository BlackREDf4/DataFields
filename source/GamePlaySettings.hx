package;

@:build(FieldMacro.build())
class GamePlaySettings
{
	private static var DataField:FlxSave = new FlxSave('gameplay', 'ninjamuffin99');

	var scrollspeed:Float = 1.0;
	var scrolltype:String = 'multiplicative';
    // anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
    // an amod example would be chartSpeed * multiplier
    // cmod would just be constantSpeed = chartSpeed
    // and xmod basically works by basing the speed on the bpm.
    // iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
    // bps is calculated by bpm / 60
    // oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
    // just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
    // oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
	var songspeed:Float = 1.0;
	var healthgain:Float = 1.0;
	var healthloss:Float = 1.0;
	var instakill:Bool = false;
	var practice:Bool = false;
	var botplay:Bool = false;
	var opponentplay:Bool = false;
}
