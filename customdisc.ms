#customdisc
#CHNaughty이 필요합니다.
@musiclist = array(
    1:array(name:'example_1',lore:array('§7example song'),time:156),
)#배열의 key number : model, name : 음악 파일 이름, lore : 재생시 보여질 이름 ,time : 음악의 길이
@music_color = 'GREEN' #재생 시 보여질 이름의 색
@music_distance = 64 #음악이 재생될 거리
@music_volume = 0.5 #음악의 볼륨
@music_drop = array(
    array(name:'MUSIC_DISC_CAT',qty:1),
    array(name:'MUSIC_DISC_11',qty:1),
    array(name:'MUSIC_DISC_13',qty:1),
    array(name:'MUSIC_DISC_BLOCKS',qty:1),
    array(name:'MUSIC_DISC_CHIRP',qty:1),
    array(name:'MUSIC_DISC_FAR',qty:1),
    array(name:'MUSIC_DISC_MALL',qty:1),
    array(name:'MUSIC_DISC_MELLOHI',qty:1),
    array(name:'MUSIC_DISC_STAL',qty:1),
    array(name:'MUSIC_DISC_STRAD',qty:1),
    array(name:'MUSIC_DISC_WAIT',qty:1),
    array(name:'MUSIC_DISC_WARD',qty:1)
)
foreach (@index in array_keys(@musiclist)){
    @push = array(name:'MUSIC_DISC_11',qty:1,meta:array(display:substr(@musiclist[@index][lore][0],2),flags:array('HIDE_POTION_EFFECTS'),lore:@musiclist[@index][lore],model:@index))
    array_push(@music_drop,@push)
}
store_value('customdiscdrop',@music_drop)
store_value('customdisclist',@musiclist)
store_value('customdisccolor',@music_color)
store_value('customdiscdistance',@music_distance)
store_value('customdiscvolume',@music_volume)


################################################################################################################################################################
bind(entity_death,null,array(type:CREEPER),@event){
    @drops = @event[drops]
    @check = 0
    @i = 0
    @index = 0
    foreach (@item in @drops){
        if (string_contains(@item[name],'MUSIC_DISC')==true){
            @check = 1
            @index = @i
        }
        @i++
    }
    if (@check == 1){
        @disc = get_value('customdiscdrop')
        @drops[@index] = array_rand(@disc,1,false)[0]
        modify_event('drops',@drops)
    }
}
############################################################################################
#custom music disc
bind(block_break,null,array(block:'JUKEBOX'),@event){
	@port = get_server_info()[11]
	@coord = @event[location][x].@event[location][y].@event[location][z]
	@coord = replace(@coord,'-','m')
    @world = @event[location][world]
	@data = get_value('customdisc'.@port.@coord.@world)
    @music = get_value('customdisclist')
    @music_distance = get_value('customdiscdistance')
	if (@data != null){
		if (@data[time]>time()){
			@musicid = @data[id]
			runas('~console','/execute at '.player().' run stopsound @a[distance=..'.@music_distance.'] record minecraft:music_disc.'.@music[@data[model]][name].'.'.@musicid)
			clear_value('customdisc'.@port.@coord.@world)
		}
        else{
            clear_value('customdisc'.@port.@coord.@world)
        }
	}
}

################################################################################################################################################################
#custom music disc
bind(player_interact,null,array(button:'right',block:'JUKEBOX'),@event){
	@hand = @event[item]
	@port = get_server_info()[11]
	@coord = @event[location][x].@event[location][y].@event[location][z]
	@coord = replace(@coord,'-','m')
    @world = @event[location][world]
	@data = get_value('customdisc'.@port.@coord.@world)
	@time = get_value(player().'cdtime')
	if (@time == null){
		@time = 0
	}
	if (@time+100>time()){
		store_value(player().'cdtime',time())
		cancel()
		die()
	}
	@music = get_value('customdisclist')
    @color = get_value('customdisccolor')
    @music_distance = get_value('customdiscdistance')
    @music_volume = get_value('customdiscvolume')
	if (@data == null){
		if (@hand==null){
			die()
		}
	}
	if (@data != null){
		if (@data[time]>time()){
			@musicid = @data[id]
			runas('~console','/execute at '.player().' run stopsound @a[distance=..80] record minecraft:music_disc.'.@music[@data[model]][name].'.'.@musicid)
			clear_value('customdisc'.@port.@coord.@world)
			die()
		}
        else{
            clear_value('customdisc'.@port.@coord.@world)
			die()
        }
    }
    if (@hand !=null){
        if (@hand[meta]!=null){
            if (array_index_exists(@hand[meta],'model')==true){
                if (@hand[meta][model]!=null){
                    @musicid = get_value('customdiscid'.@port.@hand[meta][model])
                    if (@musicid == null){
                        @musicid = 1
                    }
                    if (@musicid >10){
                        @musicid = 1
                    }
                    @data = array(model:@hand[meta][model],time:time()+@music[@hand[meta][model]][time]*1000,id:@musicid)
                    store_value('customdisc'.@port.@coord.@world,@data)
                    set_timeout(50,closure(){
                        runas('~console','/execute at '.player().' run stopsound @a[distance=..64] record minecraft:music_disc.11')
                        runas('~console','/execute at '.player().' run playsound minecraft:music_disc.'.@music[@hand[meta][model]][name].'.'.@musicid.' record @a[distance=..'.@music_distance.'] ~ ~ ~ '.@music_volume.' 1 '.@music_volume)
                        @players = players_in_radius(@event[location],80)
                        foreach (@player in @players){
                            action_msg(@player,color(@color).substr(@music[@data[model]][lore][0],2).' 재생중')
                        }
                        @musicid++
                        store_value('customdiscid'.@port.@hand[meta][model],@musicid)
                    )}
                }
            }
        }
    }
}