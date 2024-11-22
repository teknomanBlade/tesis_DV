using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class LevelManager : MonoBehaviour
{
   
    private List<IRoundChangeObserver> roundChangeObservers = new List<IRoundChangeObserver>();
    public delegate void OnRoundEndDelegate(int amountEnemies);
    public event OnRoundEndDelegate OnRoundEnd;
    [SerializeField]
    private int InitialStockUFO;
    private GameObject _panelMain;
    public GameObject WorkbenchLight;
    public GameObject YouWin;
    public GameObject YouLose;
     
    private Cat _cat;
    [SerializeField]
    public List<UFO> AllUFOs = new List<UFO>();
    public Transform[] allDoors;
    public GameObject objective;
    public bool allDoorsAreClosed;

    public delegate void LevelDelegate();
    public bool playing = true;
    public bool inRound;
    public bool InRound {
        get
        {
            return AmountEnemiesInScene > 0;
        }
    }
    [SerializeField]
    private int _amountEnemiesInScene = 0;
    public int AmountEnemiesInScene
    {
        get { return _amountEnemiesInScene; }
        set
        {
            if (_amountEnemiesInScene == value) return;
            _amountEnemiesInScene = value;
            OnRoundEnd(AmountEnemiesInScene);
            GameVars.Values.WaveManager.RoundEnd();
        }
    }
    public Player _player;
    public bool canSpawn = true;
    //CAMBIOS PARA MVC
    //Esta lista antes era de Gray, ahora se cambió a GrayModel (Sus referencias también).
    public List<Enemy> enemiesInScene = new List<Enemy>();
    public bool enemyHasObjective = false;

    private void Start()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        _panelMain = GameObject.Find("Panel");
        allDoorsAreClosed = true;
        _cat = objective.GetComponent<Cat>();
        GameVars.Values.BaseballLauncher.RestoreBuildAmount();
        GameVars.Values.MicrowaveForceFieldGenerator.RestoreBuildAmount();
        GameVars.Values.SlowTrap.RestoreBuildAmount();
        GameVars.Values.ElectricTrap.RestoreBuildAmount();
        GameVars.Values.FERNPaintballMinigun.RestoreBuildAmount();
        GameVars.Values.WaveManager.OnGrayAmountChange += GrayAmountChange;
        WorkbenchLight.SetActive(false);
    }

    private void GrayAmountChange(int newVal)
    {
        AmountEnemiesInScene = Mathf.Clamp(newVal, 0, 20);
        GameVars.Values.WaveManager.CheckIfLastRound(AmountEnemiesInScene == 0);
    }

    private void Update() 
    {
        
    }
    public void WinGame()
    {
        _player.ActiveFadeOutYouWinEffect();
        _player.SwitchKinematics();
    } 

    public void LoseGame()
    {
        _player.ActiveFadeOutYouLoseEffect();
        _player.SwitchKinematics();
        
    }

    public void RemoveUFO(UFO ufo)
    {
        if(AllUFOs.Contains(ufo)) AllUFOs.Remove(ufo);
    }
    public void AddUFO(UFO ufo)
    {
        AllUFOs.Add(ufo);
    }

    public void AddGray(Enemy gray)
    {
        enemiesInScene.Add(gray);
    }

    public void RemoveGray(Enemy gray)
    {
        enemiesInScene.Remove(gray);
        if(!InRound)
        {
            GameVars.Values.WaveManager.SendNextRound();
        }
    }

    public void CheckForObjective()
    {
        foreach (Enemy gray in enemiesInScene)
        {
            if (gray.hasObjective) 
            {
                enemyHasObjective = gray.hasObjective; //true
                canSpawn = !enemyHasObjective;
                return;
            }
            else
            {
                enemyHasObjective = false;
                canSpawn = !enemyHasObjective;
                //return;
            }
        }
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
}
