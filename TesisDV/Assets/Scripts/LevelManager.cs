using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LevelManager : MonoBehaviour, IRoundChangeObservable
{
    private List<IRoundChangeObserver> roundChangeObservers = new List<IRoundChangeObserver>();
    public PoolObject<UFOGrayDeath> UFOsPool { get; set; }
    [SerializeField]
    private UFOGrayDeath UFOPrefab;
    private int InitialStockUFO;
    private GameObject _panelMain;

    public GameObject YouWin;
    public GameObject YouLose;

    public UFO[] allUfos;
    public Transform[] allDoors;
    public GameObject objective;
    public bool allDoorsAreClosed;

    public delegate void LevelDelegate();
    public CraftingRecipe craftingRecipe;
    public bool playing = true;
    public bool inRound = false;
    public Player _player;

    public int currentRound = 0;
    public int finalRound = 5;

    public bool canSpawn = true;
    public int lastWaveEnemies = 0;
    public int enemiesAlive = 0;
    public int enemiesToSpawn = 0;

    public List<Gray> enemiesInScene = new List<Gray>();
    public bool enemyHasObjective = false;


    private void Start()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        _panelMain = GameObject.Find("Panel");
        allDoorsAreClosed = true;
        InitialStockUFO = 5;
        UFOPrefab = Resources.Load<UFOGrayDeath>("UFOGrayDeath");
        UFOsPool = new PoolObject<UFOGrayDeath>(UFOFactory, ActivateEnemy, DeactivateEnemy, InitialStockUFO, true);
        /*YouWin = Instantiate(GameVars.Values.youWinScreen);
        YouWin.transform.SetParent(_panelMain.transform);
        YouLose = Instantiate(GameVars.Values.youLoseScreen);
        YouLose.transform.SetParent(_panelMain.transform);
        ScreenManager.Instance.Push(YouWin);
        ScreenManager.Instance.Push(YouLose);*/
        craftingRecipe.RestoreBuildAmount();
        GameVars.Values.TVTrapAgain.RestoreBuildAmount();
        GameVars.Values.soundManager.PlaySound("MusicPreWave",0.14f,true);
        Invoke("EndRound",8f);
    }

    private void DeactivateEnemy(UFOGrayDeath o)
    {
        o.gameObject.SetActive(false);
        o.SetOwner(this);
        o.transform.localPosition = new Vector3(0f, 0f, 0f);
    }

    private void ActivateEnemy(UFOGrayDeath o)
    {
        o.gameObject.SetActive(true);
        o.transform.localPosition = new Vector3(0f, 10f, 40f);
    }

    private UFOGrayDeath UFOFactory()
    {
        return Instantiate(UFOPrefab);
    }

    private void Update()
    {
        //Debug.Log(allDoorsAreClosed);

        //For testing
        if (Input.GetKeyDown(KeyCode.P)) KillAllEnemiesInScene();

        canSpawn = !enemyHasObjective;
        if (_player.isDead) LoseGame();

        if (playing)
        {
            if (inRound && enemiesInScene.Count <= 0 && enemiesToSpawn <= 0 && !EnemiesSpawning()) EndRound();

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
        if (!canSpawn) return;
        foreach(UFO ufo in allUfos)
        {
            if (!ufo.spawning)
            {
                ufo.BeginSpawn();
            }
            if (enemiesToSpawn <= 0) return;
        }
    }

    public void EnemySpawned()
    {
        enemiesToSpawn--;
    }

    public void EnemyCameBack()
    {
        enemiesToSpawn++;
    }

    public void StartRound()
    {
        GameVars.Values.soundManager.PlaySound("MusicWaves", 0.16f, true);
        inRound = true;
        lastWaveEnemies = lastWaveEnemies + 2;
        enemiesToSpawn = lastWaveEnemies;
    }

    public void EndRound()
    {
        inRound = false;
        currentRound++;
        TriggerRoundChange("RoundChanged");
        Invoke("StartRound", 5f);
    }

    public void WinGame()
    {
        Debug.Log("You Win!");
        YouWin.SetActive(true);
        //SceneManager.LoadScene("MainFloor_Upgrade");
    }

    public void LoseGame()
    {
        //playing = false;
        YouLose.SetActive(true);
        Debug.Log("Loser");
        //SceneManager.LoadScene("MainFloor_Upgrade");
    }

    public void AddGray(Gray gray)
    {
        enemiesInScene.Add(gray);
    }

    public void RemoveGray(Gray gray)
    {
        enemiesInScene.Remove(gray);
    }

    public void CheckForObjective()
    {
        if (enemiesInScene.Count <= 0)
        {
            enemyHasObjective = false;
            return;
        }
        foreach (Gray gray in enemiesInScene)
        {
            enemyHasObjective = gray.hasObjective;
            if (enemyHasObjective == true) return;
        }
    }

    private void KillAllEnemiesInScene()
    {
        if (enemiesInScene.Count != 0) enemiesInScene[0].Die();
    }

    public void ChangeDoorsStatus()
    {
        if(allDoorsAreClosed)
        {
            allDoorsAreClosed = false;
        }
        else
        {
            allDoorsAreClosed = true;
        }

    }

    public void AddObserver(IRoundChangeObserver obs)
    {
        roundChangeObservers.Add(obs);
    }

    public void RemoveObserver(IRoundChangeObserver obs)
    {
        if (roundChangeObservers.Contains(obs))
            roundChangeObservers.Remove(obs);
    }

    public void TriggerRoundChange(string triggerMessage)
    {
        roundChangeObservers.ForEach(x => x.OnNotify(triggerMessage));
    }
}
