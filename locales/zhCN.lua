
local L = _G.LibStub('AceLocale-3.0'):NewLocale('FreeUI', 'zhCN')
if not L then return end

--@localization(locale="zhCN", format="lua_additive_table", handle-subnamespaces="concat")@

L['Player Frame'] = '玩家框体'
L['Pet Frame'] = '宠物框体'
L['Target Frame'] = '目标框体'
L['Target of Target Frame'] = '目标的目标框体'
L['Focus Frame'] = '焦点框体'
L['Target of Focus Frame'] = '焦点的目标框体'
L['Boss Frame'] = '首领框体'
L['Arena Frame'] = '竞技场框体'
L['Party Frame'] = '小队框体'
L['Raid Frame'] = '团队框体'
L['CustomBar'] = '额外动作条'
L['Buff Frame'] = '增益框体'
L['Debuff Frame'] = '减益框体'
L['Combat Text Incoming'] = '浮动战斗信息（受到）'
L['Combat Text Outgoing'] = '浮动战斗信息（输出）'
L['Main Bar'] = '动作条'
L['Pet Bar'] = '宠物动作条'
L['Stance Bar'] = '姿态条'
L['Leave Vehicle Button'] = '离开载具按钮'
L['Extra Button'] = '额外按钮'
L['Zone Ability Button'] = '区域技能'
L['Cooldown Icon'] = '冷却图标'
L['Player Castbar'] = '玩家施法条'
L['Target Castbar'] = '目标施法条'
L['Focus Castbar'] = '焦点施法条'
L['Vehicle Indicator'] = '载具指示器'
L['Durability Indicator'] = '耐久指示器'
L['Quest Item Button'] = '任务物品按钮'
L['Maw Threat Bar'] = '噬渊威胁条'
L['Group Tool'] = '队伍工具'
L['Objective Tracker'] = '任务追踪栏'
L['Tooltip'] = '鼠标提示'

L['Addon'] = '插件'
L['not found'] = '没有找到'
L['Disbanding group'] = '解散队伍'
L['Are you sure you want to disband the group?'] = '你确定要解散队伍？'

L['Enhanced Menu'] = '增强菜单'
L['Guild Invite'] = '邀请入会'
L['Copy Name'] = '复制名字'
L['Who'] = '查询'
L['Armory'] = '英雄榜'

L['Stats report'] = '属性报告:'
L['Covenant: %s Soulbinds: %s'] = '盟约: %s 灵魂羁绊: %s'

L['Interrupted %target%\'s %target_spell%!'] = '打断 %target% 的 %target_spell%！'
L['Dispelled %target%\'s %target_spell%!'] = '驱散 %target% 的 %target_spell%！'
L['Stolen %target%\'s %target_spell%!'] = '偷取 %target% 的 %target_spell%！'
L['%player% casted %spell% on %target%!'] = '%player% 对 %target% 施放了 %spell%！'
L['%player% casted %spell%!'] = '%player% 施放了 %spell%!'
L['Quest accept:'] = '接受任务：'
L['Announcement'] = '任务通报'
L['|nLet your teammates know the progress of quests.'] = '|n组队时向队友通报你的任务进展。'
L['%s has been reset.'] = '%s 已经重置。'
L['Can not reset %s, there are players still inside the instance.'] = '无法重置 %s，仍有玩家在副本中。'
L['Can not reset %s, there are players in your party attempting to zone into an instance.'] = '无法重置 %s, 队伍中有玩家正在进入副本。'
L['Can not reset %s, there are players offline in your party.'] = '无法重置 %s, 队伍中有玩家离线。'

L['Automatic'] = '自动交接任务'
L['|nAutomatically accept and deliver quests.|nHold SHIFT key to STOP automation.'] = '|n自动接受和完成任务。|n按住 Shift 键与 NPC 对话可以停止自动交接。'

L['%s cooldown remaining %s.'] = '%s 冷却剩余 %s'
L['%s is now available.'] = '%s 冷却完毕'

L['Press the escape key or right click to unbind this action.'] = '按 ESC 或右键撤销按键设置。'
L['Index'] = '序号'
L['Key'] = '按键'
L['bound to'] = '绑定按键'
L['Keybinds saved.'] = '按键绑定已保存。'
L['Keybinds discarded.'] = '按键绑定已撤销。'
L['All keybinds cleared for %s.'] = '%s 绑定的所有按键已清除。'

L['Addon has been out of date, the latest release is |cffff0000%s|r.'] = '插件已经过期，最新正式版为 |cffff0000%s|r'
L['Incompatible AddOns:'] = '检测到不兼容的插件:'
L['Disable Incompatible Addons'] = '禁用不兼容的插件'

L['Click to cast'] = '点击施法'
L['|nCtrl/Alt/Shift + any mouse button to binds spells.|nCast spells on party or raid frames with binded click set.|nPay attention to avoid key conflict if you enabled \'Easy Focus\' feature.'] = '|n使用 CTRL/ALT/SHIFT + 任意鼠标按键绑定技能。|n对小队/团队框体使用绑定按键即可直接施放技能。|n如果启用了快速设定焦点功能请注意避免按键冲突。'
L['Configure Spell Binding'] = '技能绑定'

L['lacking'] = '缺少'

L['World channel'] = '世界频道'
L['Join world channel'] = '加入世界频道'
L['Leave world channel'] = '离开世界频道'
L['Show chat frame'] = '显示聊天框'
L['Hide chat frame'] = '隐藏聊天框'
L['Copy chat content'] = '复制聊天内容'
L['Tell'] = '告诉'
L['From'] = '来自'

L['Stand in circle and spam <SpaceBar> to complete!'] = '站在圈内连续按空格键完成任务！'

L['Paragon'] = '典范'
L['Cursor'] = '鼠标'

L['Enter Combat'] = '进入战斗'
L['Leave Combat'] = '离开战斗'

L['Layout'] = '界面布局'
L['Grids'] = '网格'
L['Reset default anchor'] = '还原初始位置'
L['Hide the frame'] = '隐藏面板'
L['Are you sure to reset all frame\'s position?'] = '你确定要重置所有面板的位置吗？'

L['Rare'] = '稀有'
L['CastBy'] = '来自'
L['Stack'] = '堆叠'
L['Section'] = '段落'
L['TargetedBy'] = '关注'
L['iLvl'] = '装等'

L['Inventory Sort'] = '背包整理'
L['Inventory sort disabled!'] = '背包整理已禁用！'
L['Reset Position'] = '重置背包位置'
L['Toggle Bags'] = '开关背包栏位'
L['Free slots'] = '剩余空间'
L['Azerite armor'] = '艾泽里特护甲'
L['|nYou can destroy item by holding CTRL + ALT.|nThe item can be heirlooms or its quality lower then rare (blue).'] = '|n按住 CTRL + ALT 点击物品快速摧毁。|n物品品质必须低于精良（蓝色）。'
L['Quick Delete'] = '快速摧毁'
L['|nYou can now star items.|nIf \'Item Filter\' enabled, the item you starred will add to Preferences filter slots.|nThis is not available to junk.'] = '|n点击物品标记为偏好。|n如果启用了物品分类功能，偏好物品将会加入单独的偏好分类。|n该功能对垃圾物品无效。'
L['Mark Favourite'] = '标记偏好物品'
L['Auto Repair'] = '自动修理装备'
L['|nRepair your equipment automatically when you visit an able vendor.'] = '|n访问商人时自动修理装备。'
L['Auto Sell Junk'] = '自动出售垃圾'
L['|nSell junk items automtically when you visit an able vendor.'] = '|n访问商人时自动出售垃圾。'
L['Type item name to search'] = '输入物品名搜索'
L['Search'] = '搜索'
L['|nClick to tag item as junk.|nIf \'Auto sell junk\' enabled, these items would be sold as well.|nThe list is saved account-wide, and won\'t be in the export data.|nYou can hold CTRL + ALT and click to wipe the custom junk list.'] = '|n点击物品标记为垃圾。|n如果启用了自动出售垃圾功能，这些标记为垃圾的物品将被作为垃圾自动出售。|n垃圾物品列表账号共享，按住 CTRL + ALT 点击按钮可以清空列表。'
L['Mark Junk'] = '标记垃圾物品'
L['|nClick to split stacked items in your bags.|nYou can change \'split count\' for each click thru the editbox.'] = '|n点击拆分背包的堆叠物品。|n可在左侧输入框调整每次点击的拆分个数。'
L['Quick Split'] = '快速拆分'
L['Split Count'] = '拆分数量'
L['|nLeft click to deposit reagents, right click to switch deposit mode.|nIf the button is highlight, the reagents from your bags would auto deposit once you open the bank.'] = '|n左键点击存放材料，右键点击切换存放模式。|n当按钮高亮时，每当打开银行，将自动存放背包中的材料。'

L['Talent Manager'] = '天赋管理'
L['Too many sets here, please delete one of them and try again.'] = '天赋方案已满，请删除后重试。'
L['Already have a set named %s.'] = '天赋方案 %s 已存在。'
L['Not set'] = '未设定'
L['Set Name'] = '方案名称'
L['Ignored'] = '已忽略'
L['You must enter a set name.'] = '必须输入一个方案名称。'
L['Talent Set'] = '天赋方案'

L['Wowhead link']= 'Wowhead 链接'

L['Undress'] = '卸装'
L['%sUndress all|n%sUndress tabard'] = '%s卸下全身|n%s卸下战袍'
L['Right click to use vellum'] = '右键附魔至羊皮纸'
L['Stranger'] = '陌生人'
L['Account Keystones'] = '账号角色钥石信息'
L['Delete keystones info'] = '删除已保存的账号角色钥石信息'
L['Double click to unequip all gears'] = '双击卸下所有装备'
L['Hold SHIFT for details'] = '按住 SHIFT 显示详细信息'
L['Are you sure to buy |cffff0000a stack|r of these?'] = '确定购买整组？'
L['Flask'] = '合剂'
L['Lack of'] = '缺少'
L['%s players'] = '%s名玩家'
L['Start/Cancel count down'] = '开始/取消倒计时'
L['Check Flask & Food'] = '食物合剂检查'
L['All Buffs Ready!'] = '食物合剂检查: 已齐全'
L['Raid Buff Checker:'] = '食物合剂检查:'
L['ExRT Potion Check'] = 'ExRT药水使用报告'
L['You can not do it without DBM or BigWigs!'] = '必须安装DBM或者BigWigs才能使用倒计时'
L['Are you sure to |cffff0000disband|r your group?'] = '确定|cffff0000解散|r当前队伍或者团队？'
L['Raid Disbanding'] = '团队解散中'

L['Durability'] = '装备耐久'
L['Toggle Character Panel'] = '开关角色面板'
L['Friends'] = '在线好友'
L['Toggle Friends Panel'] = '开关好友列表面板'
L['Add Friend'] = '添加好友'
L['Guild'] = '公会'
L['None'] = '无'
L['Toggle Guild Panel'] = '开关公会面板'
L['Toggle Communities Panel'] = '开关社区面板'
L['Toggle Talent Panel'] = '开关天赋面板'
L['Change Specialization & Loot'] = '更改专精/拾取'
L['Daily/Weekly'] = '日常/周常'
L['Blingtron Daily Pack'] = '布林顿每日礼包'
L['Winter Veil Daily'] = '冬幕节日常'
L['Timewarped Badge Reward'] = '本周漫游徽章奖励'
L['Legion Invasion'] = '军团入侵'
L['Faction Assaults'] = '阵营突袭'
L['Current'] = '当前'
L['Next'] = '下次'
L['Lesser Vision of N\'Zoth'] = '恩佐斯的幻象统计'
L['Toggle Great Vault Panel'] = '开关宏伟宝库面板'
L['Toggle Calendar Panel'] = '开关日历面板'
L['Local Time'] = '本地时间'
L['Realm Time'] = '服务器时间'
L['Toggle Addons Panel'] = '开关插件列表界面'
L['Toggle Timer Panel'] = '开关计时器面板'
L['Earned'] = '获得'
L['Spent'] = '花费'
L['Deficit'] = '亏损'
L['Profit'] = '盈利'
L['Session'] = '本次登录'
L['Toggle Currency Panel'] = '开关货币面板'
L['Toggle Store Panel'] = '开关商店面板'
L['Reset Gold Statistics'] = '重置金币统计信息'

L['Unitframe'] = '单位框体'
L['Groupframe'] = '团队框架'
L['Nameplate'] = '姓名板'

L['Enable unitframes'] = '启用单位框体'
L['Transparent mode'] = '使用透明模式'
L['Health bar style'] = '血量条颜色风格'
L['Default white'] = '统一白色'
L['Class colored'] = '根据职业染色'
L['Percentage gradient'] = '血量百分比渐变'
L['Portrait'] = '显示动态肖像'
L['Conditional fader'] = '根据特定条件显示或隐藏'
L['Range check'] = '超出距离淡化'
L['Ouf of range alpha'] = '超出距离透明度'
L['Abbreviated name'] = '缩写名字'
L['Combat indicator'] = '战斗指示器'
L['Resting indicator'] = '休息指示器'
L['Raid target indicator'] = '队伍标记图标'
L['GCD indicator'] = '公共冷却指示器'
L['Class power bar'] = '职业资源条'
L['Class Power Bar Height'] = '职业资源条高度'
L['DK runes timer'] = '死亡骑士符文计时'
L['Monk stagger bar'] = '武僧醉拳指示器'
L['Shaman totems bar'] = '萨满图腾条'
L['Shows only debuffs created by player'] = '只显示玩家施放的减益'
L['Enable castbar'] = '启用施法条'
L['Compact style'] = '使用紧凑模式'
L['Spell name'] = '显示施放技能名称'
L['Spell timer'] = '显示施放技能计时'
L['Normal'] = '正常施法'
L['Complete'] = '施法完成'
L['Fail'] = '施法失败'
L['Uninterruptible'] = '施法不可打断'
L['Enable arena frames'] = '启用竞技场框架'
L['Enable boss frames'] = '启用首领框架'

L['Inside dungeon'] = '在副本里'
L['Inside battlefield or arena'] = '在战场或竞技场'
L['Enter combat'] = '进入战斗'
L['Have target or focus'] = '有目标或焦点'
L['Casting'] = '施法中'
L['Injured'] = '血量不满'
L['Mana not full'] = '法力不满'
L['Have power(rage/energy)'] = '有能量（比如怒气）'
L['Fade out alpha'] = '淡出透明度'
L['Fade in alpha'] = '淡入透明度'
L['Fade out duration'] = '淡出耗时'
L['Fade in duration'] = '淡入耗时'
L['Condition'] = '条件判断'
L['Fading'] = '淡入淡出设定'
L['Width'] = '长度'
L['Height'] = '高度'
L['Power Height'] = '能量条高度'
L['Alternat Power Height'] = '特殊能量条高度'
L['Gap'] = '间隔'
L['Player castbar'] = '玩家施法条'
L['Target castbar'] = '目标施法条'
L['Focus castbar'] = '焦点施法条'
L['Power Bar'] = '能量条'

L['Enable group frames'] = '启用团队框架'
L['Show names'] = '显示名字'
L['Smart layout'] = '仅超员后显示团队'
L['|nOnly show raid frames if there are more than 5 members in your group.|nIf disabled, show raid frames when in raid, show party frames when in party.'] = '|n只有当队伍人数超过5人时，才显示团队框架，小于5人则显示小队框架。|n禁用该选项，则处于团队时显示团队框架，处于小队时显示小队框架。'
L['Enable click to cast'] = '使用点击施法'
L['|nOpen your spell book to configure click to cast.'] = '|n打开技能界面配置点击施法的按键绑定。'
L['Save postion by spec'] = '根据专精保存框架位置'
L['Group filter'] = '队伍过滤'
L['Dispellable debuff highlight'] = '可驱散减益高亮'
L['Enable corner indicator'] = '使用边角指示器'
L['Show raid debuffs'] = '显示副本的重要减益效果'
L['|nShow custom major debuffs in raid and dungeons.'] = '|n在副本里根据优先级显示自定义的重要减益效果。|n只显示优先级最高的1个图标。'
L['Disable auras tooltip'] = '隐藏光环的鼠标提示'
L['Threat indicator'] = '仇恨指示器'
L['Horizontal party frames'] = '小队框架水平排列'
L['Party frames reverse grow'] = '小队框架反向增长'
L['Enable party watcher'] = '队伍技能监控'
L['Sync party watcher'] = '同步技能冷却进度'
L['|nIf enabled, the cooldown status would sync with players who using party watcher or ZenTracker(WA).|nThis might decrease your performance.'] = '|n启用后，会与队伍中使用小队冷却监控或者ZenTracker(WA)的玩家同步共享冷却状态。|n可能会导致你的性能略微下降。'
L['Horizontal raid frames'] = '团队框架水平排列'
L['Raid frames reverse grow'] = '团队框架反向增长'
L['Show buffs'] = '显示增益图标'
L['|nShow buffs on group frame by blizzard default logic, up to 3 icons.|nBetter not to use this with Corner Indicator.'] = '|n以暴雪团队框体的默认方式来显示增益效果，最多同时显示3个。|n不要和边角指示器一起使用。'
L['Show debuffs'] = '显示减益图标'
L['|nShow debuffs on group frame by blizzard default logic, up to 3 icons.'] = '|n以暴雪团队框体的默认方式来显示减益效果，最多同时显示3个。'

L['Spell ID'] = '技能 ID'
L['|nEnter spell ID, must be a number.|nYou can get ID on spell\'s tooltip.|nSpell name is not supported.'] = '|n输入法术编号，必须为数字。|n你可以在法术的鼠标提示框中看到法术ID。|n不支持直接输入法术名称。'
L['Spell Cooldown'] = '技能冷却'
L['|nEnter the spell\'s cooldown duration.|nParty watcher only support regular spells and abilities.For spells like \'Aspect of the Wild\' (BM Hunter), you need to sync cooldown with your party members.'] = '|n输入所设置法术的冷却时间。|n注意，小队技能监控只支持固定冷却时间的技能法术。对于可被缩短冷却的技能，你需要与队友同步状态。'
L['Priority'] = '优先级'
L['|nSpell\'s priority when visible.|nWhen multiple spells exist, it only remain the one that owns highest priority.|nDefault priority is 2, if you leave it blank.|nThe maximun priority is 6, and the icon would flash if you set so.'] = '|n法术图标的显示优先级。|n同一时间存在多个法术时，仅显示优先级最高的那一个。|n最高为6，同时高亮该优先级的光环。|n留空则默认为2。'
L['Show dispellable debuffs only'] = '只显示你可以驱散的减益效果'
L['Type'] = '类型'
L['|nPriority limit in 1-6.|nPress ENTER KEY when you finish typing.'] = '|n优先级仅限1-6。|n输入完毕后，按回车键保存生效。'
L['Incorrect SpellID.'] = '你输入的法术ID不存在。'
L['You need to complete all optinos.'] = '你需要完成所有的选项。'
L['The SpellID is existed.'] = '你已经添加过该法术。'
L['Are you sure to restore default list?'] = '确定重置并载入默认的列表？'

L['Enable nameplate'] = '启用姓名板'
L['Name only style'] = '友方姓名板名字模式'
L['Aura filter mode'] = '光环过滤'
L['Target indicator'] = '目标指示器'
L['Quest indicator'] = '任务指示器'
L['Excute ratio'] = '斩杀比例'
L['Classify indicator'] = '精英/稀有指示器'
L['Threat indicator'] = '仇恨指示器'
L['Totmes icon'] = '图腾图标'
L['Explosive indicator'] = '爆炸物放大'
L['Spiteful indicator'] = '怨毒目标'
L['Major spell glow'] = '重要法术高亮'
L['Spell target'] = '显示施法目标'
L['Friendly unit colored by class'] = '友方单位职业染色'
L['Hostile unit colored by class'] = '敌方单位职业染色'
L['Target unit colored'] = '目标单位染色'
L['Target color'] = '目标颜色'
L['Focus unit colored'] = '焦点单位染色'
L['Focus color'] = '焦点颜色'
L['Tank mode'] = '坦克模式仇恨染色'
L['Revert threat'] = '反转仇恨染色逻辑'
L['Secure'] = '仇恨稳固'
L['Transition'] = '仇恨不稳'
L['Insecure'] = '仇恨丢失'
L['Off-Tank'] = '副坦仇恨'
L['Custom unit colored'] = '自定义单位染色'
L['Custom color'] = '自定义颜色'
L['Custom unit list'] = '自定义单位列表'
L['BlackNWhite'] = '只显示黑白名单'
L['PlayerOnly'] = '名单+玩家'
L['IncludeCrowdControl'] = '名单+玩家+控制技能'
