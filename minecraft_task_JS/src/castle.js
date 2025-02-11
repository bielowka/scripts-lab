const towerHeight = 10;
const towerLength = 3;
const castleLength = 40;
const castleWidth = 20;
const castleHeight = 8;

player.onChat("castle", function () {
    let initialPos = player.position().add(world(10, 0, 0));
    let towers = [
        initialPos,
        initialPos.add(world(castleLength, 0, 0)),
        initialPos.add(world(castleLength, 0, castleWidth)),
        initialPos.add(world(0, 0, castleWidth))
    ];
    moat(towers[0], towers[2]);
    for (let i = 0; i < towers.length; i++) {
        buildWall(towers[i], towers[(i + 1) % towers.length].add(world(0, castleHeight, 0)));
    }
    for (let pos of towers) {
        buildTower(pos);
    }
    floor(initialPos);

    windows(towers[1], towers[2], true);
    windows(towers[0], towers[3], true);
    windows(towers[3], towers[2], false);
    entrance(towers[0], towers[1]);
})

function moat(mark1: Position, mark2: Position) {
    blocks.fill(DIRT,
        mark1.add(world(-towerLength-5, -5, -towerLength-5)),
        mark2.add(world(towerLength+5, 0, +towerLength+5)),
        FillOperation.Outline
    );
    blocks.fill(WATER,
        mark1.add(world(-towerLength - 4, -1, -towerLength - 4)),
        mark2.add(world(towerLength + 4, 0, +towerLength + 4))
    );
    blocks.fill(DIRT,
        mark1.add(world(-towerLength, -5, -towerLength)),
        mark2.add(world(towerLength, -1, +towerLength))
    );
}

function buildWall(mark1: Position, mark2: Position) {
    blocks.fill(STONE, mark1, mark2);
}

function buildTower(initialPos: Position) {
    let mark1 = initialPos.add(world(-towerLength, 0, -towerLength));
    let mark2 = initialPos.add(world(towerLength, towerHeight, towerLength));

    blocks.fill(COBBLESTONE, mark1, mark2);
    mark1 = mark1.add(world(1, 0, 1));
    mark2 = mark2.add(world(-1, 0, -1));
    blocks.fill(AIR, mark1, mark2);

    blocks.fill(STRIPPED_DARK_OAK_WOOD, mark1, mark2.add(world(0, -towerHeight, 0)));

    blocks.fill(COBBLESTONE_WALL,
        mark1.add(world(-1, 1+towerHeight, -1)),
        mark2.add(world(1, 1, 1)));

    blocks.fill(AIR,
        mark1.add(world(0, 1+towerHeight, 0)),
        mark2.add(world(0, 1, 0)));
}

function floor(initialPos: Position) {
    blocks.fill(STRIPPED_DARK_OAK_WOOD, initialPos.add(world(1, 0, 1)), initialPos.add(world(castleLength - 1, 0, castleWidth - 1)));
}

function windows(mark1: Position, mark2: Position, isWidth: boolean) {
    if (isWidth) {
        let dist = (Math.abs(mark1.getValue(Axis.Z) - mark2.getValue(Axis.Z)))/4;
        blocks.fill(IRON_BARS,
            mark1.add(world(0, 2, dist)),
            mark2.add(world(0, castleHeight-2, -(dist))),
        );
        blocks.fill(COBBLESTONE_WALL,
            mark1.add(world(0, 2, dist*2)),
            mark1.add(world(0, castleHeight - 2, dist*2)),
        );
    } else {
        let dist = (Math.abs(mark1.getValue(Axis.X) - mark2.getValue(Axis.X)));
        blocks.fill(IRON_BARS,
            mark1.add(world(dist/4 - 2, 2, 0)),
            mark1.add(world(dist/4 + 2, castleHeight - 2, 0)),
        );
        blocks.fill(IRON_BARS,
            mark1.add(world(dist / 2 - 2, 2, 0)),
            mark1.add(world(dist / 2 + 2, castleHeight - 2, 0)),
        );
        blocks.fill(IRON_BARS,
            mark2.add(world( - (dist / 4) - 2, 2, 0)),
            mark2.add(world( - (dist / 4) + 2, castleHeight - 2, 0)),
        );
    }
}

function entrance(mark1: Position, mark2: Position) {
        let dist = (Math.abs(mark1.getValue(Axis.X) - mark2.getValue(Axis.X))) / 2;
        blocks.fill(OAK_FENCE,
            mark1.add(world(dist + 3, 0, 0)),
            mark2.add(world(-dist - 3, 6, 0))
        );
        blocks.fill(OAK_FENCE_GATE,
            mark1.add(world(dist+2, 1, 0)),
            mark2.add(world(-dist-2, 5, 0))
        );
        blocks.fill(STONE_BRICKS,
            mark1.add(world(dist+2, 0, -5 - towerLength)),
            mark2.add(world(-dist-2, 0, 5 + towerLength))
        );
        blocks.fill(OAK_FENCE,
            mark1.add(world(dist + 3, 1, -5 - towerLength)),
            mark1.add(world(dist + 3, 1, 0))
        );
        blocks.fill(OAK_FENCE,
            mark2.add(world(-dist - 3, 1, -5 - towerLength)),
            mark2.add(world(-dist - 3, 1, 0))
        );
}
