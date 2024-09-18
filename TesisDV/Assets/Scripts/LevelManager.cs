using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class LevelManager : MonoBehaviour, IInRoundObservable
{
   
    private List<IRoundChangeObserver> roundChangeObservers = new List<IRoundChangeObserver>();
    private List<IInRoundObserver> inRoundObservers = new List<IInRoundObserver>();
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

    public delegate void OnGrayAmountChangeDelegate(int newVal);
    public event OnGrayAmountChangeDelegate OnGrayAmountChange;

    public delegate void LevelDelegate();
    public bool playing = true;
    public bool inRound;
    public bool InRound {
        get
        {
            if (enemiesInScene.Count == 0)
            {
                TriggerHitInRound("EndRound");
            }
            inRound = enemiesInScene.Count > 0;
            return enemiesInScene.Count > 0;
        }

    }

    private int _amountEnemiesInScene = 0;
    public int AmountEnemiesInScene
    {
        get { return _amountEnemiesInScene; }
        set
        {
            if (_amountEnemiesInScene == value) return;
            _amountEnemiesInScene = value;
            OnGrayAmountChange?.Invoke(_amountEnemiesInScene);
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
        
        WorkbenchLight.SetActive(false);
    }
   
    private void Update()
    {
        AmountEnemiesInScene = GameVars.Values.WaveManager.GetAmountEnemiesByWave();
        if (Input.GetKeyDown(KeyCode.P)) KillAllEnemiesInScene();
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

    private void KillAllEnemiesInScene()
    {
        if (enemiesInScene.Count != 0) 
        {
            if (!enemiesInScene[0].gameObject.CompareTag("Tutorial"))
                AmountEnemiesInScene--;
            enemiesInScene[0].TakeDamage(999);
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

    public void AddObserverInRound(IInRoundObserver obs)
    {
        inRoundObservers.Add(obs);
    }

    public void RemoveObserverInRound(IInRoundObserver obs)
    {
        if(inRoundObservers.Contains(obs)) inRoundObservers.Remove(obs);
    }

    public void TriggerHitInRound(string triggerMessage)
    {
        inRoundObservers.ForEach(x => x.OnNotifyInRound(triggerMessage));
    }
}
