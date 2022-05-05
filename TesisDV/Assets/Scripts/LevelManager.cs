using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LevelManager : MonoBehaviour
{
    private GameObject _panelMain;

    public YouWinScreen YouWin { get; private set; }
    public YouLoseScreen YouLose { get; private set; }

    public UFO[] allUfos;

    public delegate void LevelDelegate();
    public CraftingRecipe craftingRecipe;
    public bool playing = true;
    public bool inRound = false;
    public Player _player;

    public int currentRound = 0;
    public int finalRound = 5;

    public int lastWaveEnemies = 0;
    public int enemiesAlive = 0;
    public int enemiesToSpawn = 0;


    private void Start()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        _panelMain = GameObject.Find("Panel");
        YouWin = Instantiate(GameVars.Values.youWinScreen);
        YouWin.transform.SetParent(_panelMain.transform);
        YouLose = Instantiate(GameVars.Values.youLoseScreen);
        YouLose.transform.SetParent(_panelMain.transform);
        ScreenManager.Instance.Push(YouWin);
        ScreenManager.Instance.Push(YouLose);
        craftingRecipe.RestoreBuildAmount();
        EndRound();
    }

    private void Update()
    {
        if (_player.isDead) LoseGame();

        if (playing)
        {
            if (inRound && enemiesAlive <= 0 && enemiesToSpawn <= 0 && !EnemiesSpawning()) EndRound();

            if (inRound && enemiesToSpawn > 0)
            {
                SpawnWave();
            }
        }

        if (currentRound > finalRound)
        {
            playing = false;
            Invoke("WinGame", 3f);
        }
    }

    public bool EnemiesSpawning()
    {
        foreach (UFO ufo in allUfos)
        {
            if (ufo.spawning) return true;
        }
        return false;
    }

    public void SpawnWave()
    {
        foreach(UFO ufo in allUfos)
        {
            if (!ufo.spawning)
            {
                ufo.BeginSpawn();
            }
            if (enemiesToSpawn <= 0) return;
        }
    }

    public void EnemyDied()
    {
        enemiesAlive--;
    }

    public void EnemySpawned()
    {
        enemiesToSpawn--;
        enemiesAlive++;
    }

    public void StartRound()
    {
        inRound = true;
        lastWaveEnemies = lastWaveEnemies + 2;
        enemiesToSpawn = lastWaveEnemies;
    }

    public void EndRound()
    {
        inRound = false;
        currentRound++;
        Invoke("StartRound", 5f);
    }

    public void WinGame()
    {
        Debug.Log("You Win!");
        YouWin.ActiveScreen();
        //SceneManager.LoadScene("MainFloor_Upgrade");
    }

    public void LoseGame()
    {
        //playing = false;
        YouLose.ActiveScreen();
        Debug.Log("Loser");
        //SceneManager.LoadScene("MainFloor_Upgrade");
    }
}
