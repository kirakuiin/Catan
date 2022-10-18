extends Node


class_name MapData


const MAP_DATA = {
    Data.CatanSize.SMALL: {
        Data.SeafarerMap.NEW_SHORE: {
            "main": [
                Vector3(-1, -1, 2), Vector3(-1, 0, 1), Vector3(0, -1, 1), Vector3(0, -2, 2),
                Vector3(-1, -2, 3), Vector3(-2, -1, 3), Vector3(-2, 0, 2), Vector3(-2, 1, 1),
                Vector3(-1, 1, 0), Vector3(0, 0, 0), Vector3(1, -1, 0), Vector3(1, -2, 1),
                Vector3(1, -3, 2), Vector3(0, -3, 3), Vector3(-1, -3, 4), Vector3(-2, -2, 4),
                Vector3(-3, -1, 4), Vector3(-3, 0, 3), Vector3(-3, 1, 2)],
            "island": [
                Vector3(-3, 3, 0), Vector3(0, 2, -2), Vector3(-1, 3, -2), Vector3(3, -4, 1),
                Vector3(3, -3, 0), Vector3(3, -1, -2), Vector3(3, 0, -3), Vector3(2, 1, -3),
            ],
        },
        Data.SeafarerMap.FOUR_ISLAND: {
            "main": [
                Vector3(-3, -1, 4), Vector3(-3, 0, 3), Vector3(-3, 2, 1), Vector3(-3, 3, 0),
                Vector3(-2, -2, 4), Vector3(-2, -1, 3), Vector3(-2, 2, 0), Vector3(-2, 3, -1),
                Vector3(1, -4, 3), Vector3(1, -3, 2), Vector3(1, -2, 1), Vector3(1, 0, -1),
                Vector3(2, -4, 2), Vector3(2, -3, 1), Vector3(2, 0, -2), Vector3(2, 1, -3),
                Vector3(3, -4, 1), Vector3(3, -3, 0), Vector3(3, -1, -2), Vector3(3, 0, -3),
                Vector3(-1, 1, 0), Vector3(-1, 2, -1), Vector3(-1, 3, -2)
            ],
            "island": [],
        }
    },
    Data.CatanSize.BIG: {
        Data.SeafarerMap.NEW_SHORE: {
            "main": [
                Vector3(0, 0, 0), Vector3(0, 1, -1), Vector3(1, 0, -1), Vector3(1, -1, 0),
                Vector3(0, -1, 1), Vector3(-1, 0, 1), Vector3(-1, 1, 0), Vector3(-1, 2, -1), 
                Vector3(0, 2, -2), Vector3(1, 1, -2), Vector3(2, 0, -2), Vector3(2, -1, -1),
                Vector3(2, -2, 0), Vector3(1, -2, 1), Vector3(0, -2, 2), Vector3(-1, -1, 2),
                Vector3(-2, 0, 2), Vector3(-2, 1, 1), Vector3(-2, 2, 0), Vector3(3, -1, -2),
                Vector3(3, -2, -1), Vector3(3, -3, 0), Vector3(2, -3, 1), Vector3(1, -3, 2),
                Vector3(0, -3, 3), Vector3(-1, -2, 3), Vector3(-2, -1, 3), Vector3(-3, 0, 3),
                Vector3(-3, 1, 2), Vector3(-3, 2, 1),
            ],
            "island": [
                Vector3(1, -5, 4), Vector3(2, -5, 3), Vector3(3, -5, 2), Vector3(-3, -2, 5),
                Vector3(-2, -3, 5), Vector3(-1, -4, 5), Vector3(1, 3, -4), Vector3(3, 1, -4),
                Vector3(-1, 4, -3), Vector3(-3, 4, -1),
            ],
        },
    },
}

