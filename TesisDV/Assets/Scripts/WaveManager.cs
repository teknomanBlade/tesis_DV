using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveManager : MonoBehaviour, IRoundChangeObservable
{
    private List<IRoundChangeObserver> roundChangeObservers = new List<IRoundChangeObserver>();

    private Coroutine _currentCoroutine;
    private GameObject parent;  
    [SerializeField]
    private UFO _myUFO;
    [SerializeField] private Enemy _myEnemy;

    [Header("Wave Details")]
    [SerializeField]
    private int _currentRound;
    public int CurrentRound
    {
        get { return _currentRound; }
        set
        {
            if (_currentRound == value) return;
            _currentRound = value;
            OnRoundChanged?.Invoke(_currentRound);
        }
    }
    /* [SerializeField]
    private float _firstWaveDelay; */
    [SerializeField] private float _timeBetweenWaves;

    private bool _inRound;
    public bool InRound
    {
        get { return _inRound;  }
        set { _inRound = value; }
    }
    [SerializeField] private float _timeWaves = 0;
    public float TimeWaves
    {
        get { return _timeWaves; }
        set
        {
            if (_timeWaves == value) return;
            _timeWaves = value;
            OnTimeWaveChange?.Invoke(_timeWaves);
            
        }
    }
    [SerializeField] private int _totalRounds;

    [SerializeField] private Vector3 _startingPos;

    [Header("UFO 1 Details")]
    [SerializeField] private Vector3 _finalPos1;
    [SerializeField] private List<Enemy> _graysUFO1;
    [SerializeField] private List<Enemy> _graysUFO12;
    [SerializeField] private List<Enemy> _graysUFO13;
    [SerializeField] private List<Enemy> _graysUFO14;
    [SerializeField] private List<Enemy> _graysUFO15;
    [SerializeField] private List<Enemy> _graysUFO16;

    [Header("UFO 2 Details")]

    [SerializeField] private Vector3 _finalPos2;
    [SerializeField] private List<Enemy> _graysUFO2;
    [SerializeField] private List<Enemy> _graysUFO22;
    [SerializeField] private List<Enemy> _graysUFO23;
    [SerializeField] private List<Enemy> _graysUFO24;
    [SerializeField] private List<Enemy> _graysUFO25;
    [SerializeField] private List<Enemy> _graysUFO26;

    [SerializeField] private GameObject UFOIndicatorPrefab;
    private GameObject UFOIndicator;
    private GameObject UFOIndicator2;
    public delegate void OnRoundChangedDelegate(int newVal);
    public event OnRoundChangedDelegate OnRoundChanged;
    public delegate void OnTimeWaveChangeDelegate(float newVal);
    public event OnTimeWaveChangeDelegate OnTimeWaveChange;
    public delegate void OnRoundStartEndDelegate(bool roundStart);
    public event OnRoundStartEndDelegate OnRoundStartEnd;
    public delegate void OnRoundEndDelegate(int round);
    public event OnRoundEndDelegate OnRoundEnd;



    [SerializeField] private List<Transform> _waypoints;
    [SerializeField] private Vector3 _startingPosHard;

    void Awake()
    {
        TimeWaves = _timeBetweenWaves;
        //_currentCoroutine = StartCoroutine("WaitFirstDelay");
    }

    void Start()
    {
        parent = GameObject.Find("MainGame");
        //OnRoundStartEnd(_inRound);
        //Debug.Log(_inRound);
        OnRoundEnd(_currentRound);
        InstantiateUFOIndicators();
    }

    void Update()
    {
        if (_inRound)
        {
            TimeWaves -= Time.deltaTime;

            if(TimeWaves <= 0)
            {
                SendUFOS();
            }
        }  
    }

    /*  IEnumerator WaitFirstDelay()
     {
         DespawnUFOIndicators();
         yield return new WaitForSeconds(_firstWaveDelay);
         SpawnWave();

     } */

    public void EnhanceEnemyStatsPerWave(Enemy e)
    {
        if (CurrentRound == 3)
        {
            AugumentStatsPerType(e, CurrentRound);
        }
        else if (CurrentRound == 4)
        {
            AugumentStatsPerType(e, CurrentRound);
        }
        else if (CurrentRound == 5)
        {
            AugumentStatsPerType(e, CurrentRound);
        }
        else if (CurrentRound == 6)
        {
            AugumentStatsPerType(e, CurrentRound);
        }
        else if (CurrentRound == 7)
        {
            AugumentStatsPerType(e, CurrentRound);
        }
    }

    public void AugumentStatsPerType(Enemy e, int CurrentRound)
    {
        if (e.enemyType == EnemyType.Common)
        {
            e.HP += CurrentRound;
            Debug.Log("COMMON GRAY NEW LIFE: " + e.HP + " ROUND: " + CurrentRound);
        }
        else if (e.enemyType == EnemyType.Melee)
        {
            e.HP += CurrentRound;
            Debug.Log("MELEE GRAY NEW LIFE: " + e.HP + " ROUND: " + CurrentRound);
        }
        else if (e.enemyType == EnemyType.Dog)
        {
            e.HP += CurrentRound;
            Debug.Log("GRAY DOG NEW LIFE: " + e.HP + " ROUND: " + CurrentRound);
        }
        else if (e.enemyType == EnemyType.Tank && CurrentRound == 7)
        {
            e.HP += CurrentRound;
            Debug.Log("TANK GRAY NEW LIFE: " + e.HP + " ROUND: " + CurrentRound);
        }
    }

    IEnumerator WaitBetweenWaves()
    {
        //DespawnUFOIndicators();
        yield return new WaitForSeconds(_timeBetweenWaves);
        SpawnWave();
    }

    public void StartRound()
    {
        TimeWaves = _timeBetweenWaves;
        _inRound = true;
        OnRoundStartEnd(_inRound);
        //SendUFOS();
    }

    private void SendUFOS()
    {
        _inRound = false;
        OnRoundStartEnd(_inRound);

        DisableUFOLR(); 
        SpawnWave();
        GameVars.Values.soundManager.PlaySound("MusicWaves", 0.16f, true);
        //_inRound = true;
        //OnRoundStartEnd?.Invoke(_inRound);
        TimeWaves = _timeBetweenWaves;
    }

    private void SpawnWave()
    {
        //InstantiateUFOIndicators(); Ahora los indicadores aparecen entre rondas.
        if (_currentRound < _totalRounds)
        {
            CurrentRound++;
            //TriggerRoundChange("RoundChanged");
            if(_currentRound == 1)
            {
                Instantiate(_myEnemy, parent.transform).SetSpawnPos(_startingPosHard).SetPathHard(_waypoints);//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            if(_currentRound == 2)
            {
                Instantiate(_myUFO, parent.transform).SetSpawnPos(_startingPos).SetFinalPos(_finalPos1).SetGraysToSpawn(_graysUFO1);//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform).SetSpawnPos(_startingPos).SetFinalPos(_finalPos2).SetGraysToSpawn(_graysUFO2);//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 3)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO12);//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO22);//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 4)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO13);//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO23);//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 5)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO14);//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO24);//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 6)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO15);//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO25);//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 7)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO16);//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO26);//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            
        }
        /* else
        {
            GameVars.Values.LevelManager.WinGame(); Chequear si ganaste aca hace que tengas que esperar todo el tiempo InBetweenRounds.
        } */
    }

    //Hacer por evento en lugar de void publico.
    public void SendNextRound()
    {
        if (_currentRound >= _totalRounds)
        {
            Invoke(nameof(SendWinGame), 1f);
            return;
        }
        _inRound = false;
        OnRoundStartEnd?.Invoke(_inRound);
        OnRoundEnd(_currentRound);
        RestartUFOIndicators();
        //if(_currentCoroutine != null) StopCoroutine(_currentCoroutine);
        //_currentCoroutine = StartCoroutine("WaitBetweenWaves");
    }

    private void RestartUFOIndicators()
    {
        Destroy(UFOIndicator);
        Destroy(UFOIndicator2);
        InstantiateUFOIndicators();
    }

    private void DisableUFOLR()
    {
        UFOIndicator.GetComponent<UFOLandingIndicator>().DisableLineRenderer();
        UFOIndicator2.GetComponent<UFOLandingIndicator>().DisableLineRenderer();
    }    

    private void SendWinGame()
    {
        GameVars.Values.LevelManager.WinGame(); 
    }

    private void InstantiateUFOIndicators()
    {
        Vector3 auxVector = new Vector3(_finalPos1.x, 0f, _finalPos1.z);
        UFOIndicator = Instantiate(UFOIndicatorPrefab);
        UFOIndicator.transform.position = auxVector;

        Vector3 auxVector2 = new Vector3(_finalPos2.x, 0.05f, _finalPos2.z);
        UFOIndicator2 = Instantiate(UFOIndicatorPrefab);
        UFOIndicator2.transform.position = auxVector2;
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

    public int GetCurrentRound()
    {
        return _currentRound;
    }
}
