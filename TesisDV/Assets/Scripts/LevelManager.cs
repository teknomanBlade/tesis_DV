using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LevelManager : MonoBehaviour
{
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
        SceneManager.LoadScene("MainFloor_Upgrade");
    }

    public void LoseGame()
    {
        //playing = false;
        Debug.Log("Loser");
        SceneManager.LoadScene("MainFloor_Upgrade");
    }
}
