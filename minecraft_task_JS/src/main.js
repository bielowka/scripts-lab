
// Funkcja, która uruchomi budowę
player.onChat("run", function () {
  agent.setItem(STONE, 64, 1); // Ustawienie kamienia w ekwipunku agenta
  agent.setItem(GLASS, 64, 2); // Ustawienie szkła w ekwipunku agenta

  buildCastle(); // Uruchomienie funkcji budującej zamek
});

// Funkcja budująca cały zamek
function buildCastle() {
  agent.teleportToPlayer(); // Teleportacja agenta do gracza
  agent.move(FORWARD, 10); // Przesunięcie agenta o 10 bloków do przodu

  agent.turn(WEST); // Obracamy agenta na zachód

  let initialPos = agent.getPosition(); // Pozycja początkowa agenta
  buildTower(initialPos); // Budowanie ścian
}

function buildTowers(initialPos: Position) {
  for (let i = 0; i < 4; i++) {
    buildTower(initialPos);
    agent.turnRight();
    agent.turnRight();
    agent.move(FORWARD, 20);
    agent.turnLeft();
  }
}


function buildTower(initialPos: Position) {
  agent.teleport(initialPos, WEST);
  agent.move(FORWARD, 3);
  for (let i = 0; i < 4; i++) {
    for (let x = 0; x < 3; x++) {
      for (let y = 0; y < 8; y++) {
        agent.place(DOWN);
        agent.move(UP, 1);
      }
      agent.move(BACK, 1);
      agent.move(DOWN, 8);
      agent.turnRight();
      agent.move(FORWARD, 1);
      agent.turnLeft();
      agent.move(FORWARD, 1);
    }
    agent.turnRight();
    agent.turnRight();
    agent.move(FORWARD, 1);
    agent.turnLeft();
  }
}

