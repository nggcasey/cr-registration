Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'

Config.Peds = {
    -- Driving School
    [1] = {
        ['model'] = 'A_F_Y_Business_04',
        ['coords'] = vector4(218.14, -1388.81, 29.6, 273.77),
        ['scenario'] = 'WORLD_HUMAN_STAND_MOBILE',
    },
    [2] = {
        ['model'] = 'A_M_M_Business_01',
        ['coords'] = vector4(215.14, -1386.08, 29.6, 266.83),
        ['scenario'] = 'WORLD_HUMAN_CLIPBOARD',
    }
}

Config.Fees = {
    { --30 Days Registration
        ['fee'] = 2500,
        ['days'] = 30
    },
    { --60 Days Registration
        ['fee'] = 5000,
        ['days'] = 60
    },
    { --90 Days Registration
        ['fee'] = 7500,
        ['days'] = 90
    }
}