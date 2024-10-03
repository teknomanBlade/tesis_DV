using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class WaveManager : MonoBehaviour, IRoundChangeObservable
{
    private List<IRoundChangeObserver> roundChangeObservers = new List<IRoundChangeObserver>();
   
    private Coroutine _currentCoroutine;
    [SerializeField]
    private GameObject parent;  
    public GameObject MainGameParent 
    {
        get { return parent; }
        set { parent = value; }
    }
    [SerializeField]
    private UFO _myUFO;
    [SerializeField] private Enemy _myEnemy;
    public int InitialStock { get; private set; }
    public GrayModel GrayCommonPrefab;
    public TallGrayModel TallGrayPrefab;
    public TankGrayModel TankGrayPrefab;
    public GrayDogModel GrayDogPrefab;
    public PoolObject<GrayModel> GrayCommonPool { get; set; }
    public PoolObject<TallGrayModel> TallGrayPool { get; set; }
    public PoolObject<TankGrayModel> TankGrayPool { get; set; }
    public PoolObject<GrayDogModel> GrayDogPool { get; set; }

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
    [SerializeField]
    private bool _inRound;
    public bool InRound
    {
        get 
        {
            return _inRound;  
        }
        set 
        {
            
            _inRound = value; 
        }
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
    public delegate void OnGrayAmountChangeDelegate(int newVal);
    public event OnGrayAmountChangeDelegate OnGrayAmountChange;
    [SerializeField] private List<Transform> _waypoints;
    [SerializeField] private Vector3 _startingPosHard;
    [SerializeField] private AudioSource _as;
    void Awake()
    {
        MainGameParent = GameObject.Find("MainGame");
        TimeWaves = _timeBetweenWaves;
        InitialStock = 5;
        GrayCommonPool = new PoolObject<GrayModel>(GrayCommonFactory, ActivateGrayCommon, DeactivateGrayCommon, InitialStock, true);
        TallGrayPool = new PoolObject<TallGrayModel>(TallGrayFactory, ActivateTallGray, DeactivateTallGray, InitialStock, true);
        TankGrayPool = new PoolObject<TankGrayModel>(TankGrayFactory, ActivateTankGray, DeactivateTankGray, InitialStock, true);
        GrayDogPool = new PoolObject<GrayDogModel>(GrayDogFactory, ActivateGrayDog, DeactivateGrayDog, InitialStock, true);
        LoadEnemiesInWaves();
    }
    public void LoadEnemiesInWaves() 
    {
        ClearAllEnemiesLists();
        //Wave 1
        _graysUFO1.Add(GetEnemiesTypeForWave(2, EnemyType.Common).FirstOrDefault());
        _graysUFO2.Add(GetEnemiesTypeForWave(2, EnemyType.Common).LastOrDefault());
        //Wave 2
        _graysUFO12.Add(GetEnemiesTypeForWave(1, EnemyType.Dog).FirstOrDefault());
        _graysUFO22.AddRange(GetEnemiesTypeForWave(3, EnemyType.Common));
        //Wave 3
        _graysUFO13.AddRange(GetEnemiesTypeForWave(2, EnemyType.Dog));
        _graysUFO23.AddRange(GetEnemiesTypeForWave(4, EnemyType.Common));
        //Wave 4
        _graysUFO14.Add(GetEnemiesTypeForWave(1, EnemyType.Common).FirstOrDefault());
        _graysUFO14.Add(GetEnemiesTypeForWave(1, EnemyType.Dog).FirstOrDefault());
        _graysUFO14.Add(GetEnemiesTypeForWave(1, EnemyType.Melee).FirstOrDefault());
        _graysUFO24.Add(GetEnemiesTypeForWave(1, EnemyType.Common).FirstOrDefault());
        _graysUFO24.Add(GetEnemiesTypeForWave(1, EnemyType.Dog).FirstOrDefault());
        _graysUFO24.Add(GetEnemiesTypeForWave(1, EnemyType.Melee).FirstOrDefault());
        //Wave 5
        _graysUFO15.AddRange(GetEnemiesTypeForWave(3, EnemyType.Melee));
        _graysUFO25.AddRange(GetEnemiesTypeForWave(2, EnemyType.Common));
        _graysUFO25.Add(GetEnemiesTypeForWave(1, EnemyType.Dog).FirstOrDefault());
        //Wave 6
        _graysUFO16.Add(GetEnemiesTypeForWave(1, EnemyType.Common).FirstOrDefault());
        _graysUFO16.Add(GetEnemiesTypeForWave(1, EnemyType.Dog).FirstOrDefault());
        _graysUFO16.Add(GetEnemiesTypeForWave(1, EnemyType.Melee).FirstOrDefault());
        _graysUFO16.Add(GetEnemiesTypeForWave(1, EnemyType.Tank).FirstOrDefault());
        _graysUFO26.Add(GetEnemiesTypeForWave(1, EnemyType.Common).FirstOrDefault());
        _graysUFO26.Add(GetEnemiesTypeForWave(1, EnemyType.Dog).FirstOrDefault());
        _graysUFO26.Add(GetEnemiesTypeForWave(1, EnemyType.Melee).FirstOrDefault());
        _graysUFO26.Add(GetEnemiesTypeForWave(1, EnemyType.Tank).FirstOrDefault());
    }
    public void ClearAllEnemiesLists() 
    {
        _graysUFO1.Clear();
        _graysUFO12.Clear();
        _graysUFO13.Clear();
        _graysUFO14.Clear();
        _graysUFO15.Clear();
        _graysUFO16.Clear();
        _graysUFO2.Clear();
        _graysUFO22.Clear();
        _graysUFO23.Clear();
        _graysUFO24.Clear();
        _graysUFO25.Clear();
        _graysUFO26.Clear();
    }
    private List<Enemy> GetEnemiesTypeForWave(int amount, EnemyType type)
    {
        var enemiesList = new List<Enemy>();
        if (type == EnemyType.Common)
        {
            for (int i = 0; i < amount; i++)
            {
                enemiesList.Add(GrayCommonPool.GetObjectDisabled());
            }
        }
        else if (type == EnemyType.Melee) 
        {
            for (int i = 0; i < amount; i++)
            {
                enemiesList.Add(TallGrayPool.GetObjectDisabled());
            }
        }
        else if (type == EnemyType.Tank)
        {
            for (int i = 0; i < amount; i++)
            {
                enemiesList.Add(TankGrayPool.GetObjectDisabled());
            }
        }
        else if (type == EnemyType.Dog)
        {
            for (int i = 0; i < amount; i++)
            {
                enemiesList.Add(GrayDogPool.GetObjectDisabled());
            }
        }
        return enemiesList;
    }
    public int GetAmountEnemiesByWave() 
    {
        var amount = 0;
        if (CurrentRound == 1) 
        {
            amount = _graysUFO1.Union(_graysUFO2).ToList().Count;
        }
        if (CurrentRound == 2)
        {
            amount = _graysUFO12.Union(_graysUFO22).ToList().Count;
        }
        if (CurrentRound == 3)
        {
            amount = _graysUFO13.Union(_graysUFO23).ToList().Count;
        }
        if (CurrentRound == 4)
        {
            amount = _graysUFO14.Union(_graysUFO24).ToList().Count;
        }
        if (CurrentRound == 5)
        {
            amount = _graysUFO15.Union(_graysUFO25).ToList().Count;
        }
        if (CurrentRound == 6)
        {
            amount = _graysUFO16.Union(_graysUFO26).ToList().Count;
        }

        return amount;
    }
    private GrayDogModel GrayDogFactory()
    {
        return Instantiate(GrayDogPrefab);
    }
    private void DeactivateGrayDog(GrayDogModel o)
    {
        o.gameObject.transform.parent = MainGameParent.transform;
        o.gameObject.SetActive(false);
    }

    private void ActivateGrayDog(GrayDogModel o)
    {
        o.gameObject.SetActive(true);
        o.onStatsEnhanced += EnhanceEnemyStatsPerWave;
    }
    private TankGrayModel TankGrayFactory()
    {
        return Instantiate(TankGrayPrefab);
    }
    private void DeactivateTankGray(TankGrayModel o)
    {
        o.gameObject.transform.parent = MainGameParent.transform;
        o.gameObject.SetActive(false);
    }

    private void ActivateTankGray(TankGrayModel o)
    {
        o.gameObject.SetActive(true);
        o.onStatsEnhanced += EnhanceEnemyStatsPerWave;
    }
    private TallGrayModel TallGrayFactory()
    {
        return Instantiate(TallGrayPrefab);
    }
    private void DeactivateTallGray(TallGrayModel o)
    {
        o.gameObject.transform.parent = MainGameParent.transform;
        o.gameObject.SetActive(false);
    }

    private void ActivateTallGray(TallGrayModel o)
    {
        o.gameObject.SetActive(true);
        o.onStatsEnhanced += EnhanceEnemyStatsPerWave;
    }
    private GrayModel GrayCommonFactory()
    {
        return Instantiate(GrayCommonPrefab);
    }
    private void DeactivateGrayCommon(GrayModel o)
    {
        o.gameObject.transform.parent = MainGameParent.transform;
        o.gameObject.SetActive(false);
    }

    private void ActivateGrayCommon(GrayModel o)
    {
        o.gameObject.SetActive(true);
        o.onStatsEnhanced += EnhanceEnemyStatsPerWave;
    }
    void Start()
    {
        
        _as = GetComponent<AudioSource>();
        GameVars.Values.soundManager.PlaySound(_as,"MusicPreWave", 0.1f, true,0f);
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
    public void EnhanceEnemyStatsPerWave(Enemy e)
    {
        AugumentStatsPerType(e, CurrentRound);
    }

    public void AugumentStatsPerType(Enemy e, int CurrentRound)
    {
        if (e.enemyType == EnemyType.Common)
        {
            e.HP = GrayCommonHPByRoundInterval(CurrentRound);
            Debug.Log("COMMON GRAY NEW LIFE: " + e.HP + " ROUND: " + CurrentRound);
        }
        else if (e.enemyType == EnemyType.Melee)
        {
            e.HP = GrayMeleeHPByRoundInterval(CurrentRound);
            Debug.Log("MELEE GRAY NEW LIFE: " + e.HP + " ROUND: " + CurrentRound);
        }
        else if (e.enemyType == EnemyType.Dog)
        {
            e.HP = GrayDogHPByRoundInterval(CurrentRound);
        }
        else if (e.enemyType == EnemyType.Tank && CurrentRound == 7)
        {
            e.HP = GrayTankHPByRoundInterval(CurrentRound);
            Debug.Log("TANK GRAY NEW LIFE: " + e.HP + " ROUND: " + CurrentRound);
        }
    }
    public float GrayCommonHPByRoundInterval(int CurrentRound)
    {
        var hpResult = 0f;
        if (CurrentRound > 0 && CurrentRound <= 3)
        {
            hpResult = 3f;
            Debug.Log("GRAY COMMON NEW LIFE IF: " + hpResult + " ROUND: " + CurrentRound);
        }
        else if (CurrentRound > 3 && CurrentRound <= 5)
        {
            hpResult = 6f;
            Debug.Log("GRAY COMMON NEW LIFE ELSE IF: " + hpResult + " ROUND: " + CurrentRound);
        }
        else if (CurrentRound > 5 && CurrentRound <= 7)
        {
            hpResult = 9f;
            Debug.Log("GRAY COMMON NEW LIFE SECOND ELSE IF: " + hpResult + " ROUND: " + CurrentRound);
        }

        return hpResult;
    }

    public float GrayMeleeHPByRoundInterval(int CurrentRound)
    {
        var hpResult = 0f;
        if (CurrentRound > 0 && CurrentRound <= 3)
        {
            hpResult = 8f;
            Debug.Log("GRAY MELEE NEW LIFE IF: " + hpResult + " ROUND: " + CurrentRound);
        }
        else if (CurrentRound > 3 && CurrentRound <= 5)
        {
            hpResult = 12f;
            Debug.Log("GRAY MELEE NEW LIFE ELSE IF: " + hpResult + " ROUND: " + CurrentRound);
        }
        else if (CurrentRound > 5 && CurrentRound <= 7)
        {
            hpResult = 16f;
            Debug.Log("GRAY MELEE NEW LIFE SECOND ELSE IF: " + hpResult + " ROUND: " + CurrentRound);
        }

        return hpResult;
    }

    public float GrayDogHPByRoundInterval(int CurrentRound) 
    {
        var hpResult = 0f;
        if (CurrentRound > 0 && CurrentRound <= 3)
        {
            hpResult = 1.5f;
            Debug.Log("GRAY DOG NEW LIFE IF: " + hpResult + " ROUND: " + CurrentRound);
        }
        else if (CurrentRound > 3 && CurrentRound <= 5)
        {
            hpResult = 2f;
            Debug.Log("GRAY DOG NEW LIFE ELSE IF: " + hpResult + " ROUND: " + CurrentRound);
        }
        else if (CurrentRound > 5 && CurrentRound <= 7) 
        {
            hpResult = 2.5f;
            Debug.Log("GRAY DOG NEW LIFE SECOND ELSE IF: " + hpResult + " ROUND: " + CurrentRound);
        }

        return hpResult;
    }

    public float GrayTankHPByRoundInterval(int CurrentRound)
    {
        var hpResult = 0f;
        if (CurrentRound == 6)
        {
            hpResult = 20f;
            Debug.Log("GRAY DOG NEW LIFE IF: " + hpResult + " ROUND: " + CurrentRound);
        }
        else if (CurrentRound == 7)
        {
            hpResult = 24f;
            Debug.Log("GRAY DOG NEW LIFE ELSE IF: " + hpResult + " ROUND: " + CurrentRound);
        }

        return hpResult;
    }


    IEnumerator WaitBetweenWaves()
    {
        yield return new WaitForSeconds(_timeBetweenWaves);
        SpawnWave();
    }

    public void StartRound()
    {
        TimeWaves = _timeBetweenWaves;
        _inRound = true;
        OnRoundStartEnd(_inRound);
        OnGrayAmountChange(GetAmountEnemiesByWave());
    }

    private void SendUFOS()
    {
        _inRound = false;
        OnRoundStartEnd(_inRound);

        DisableUFOLR(); 
        SpawnWave();
        GameVars.Values.soundManager.PlaySound(_as,"MusicWaves", 0.12f, true,0f);
        TimeWaves = _timeBetweenWaves;
    }

    private void SpawnWave()
    {
        if (_currentRound < _totalRounds)
        {
            CurrentRound++;
            if(_currentRound == 1)
            {
                Instantiate(_myEnemy, parent.transform).SetSpawnPos(_startingPosHard).SetPathHard(_waypoints);//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            if(_currentRound == 2)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO1).SetName("a");//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO2).SetName("b");//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 3)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO12).SetName("a");//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO22).SetName("b");//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 4)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO13).SetName("a");//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO23).SetName("b");//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 5)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO14).SetName("a");//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO24).SetName("b");//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 6)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO15).SetName("a");//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO25).SetName("b");//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            else if(_currentRound == 7)
            {
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos1)
                    .SetGraysToSpawn(_graysUFO16).SetName("a");//.SetRotation(new Vector3(-90f, 0f, 0f));
                Instantiate(_myUFO, parent.transform)
                    .SetSpawnPos(_startingPos)
                    .SetFinalPos(_finalPos2)
                    .SetGraysToSpawn(_graysUFO26).SetName("b");//.SetRotation(new Vector3(-90f, 0f, 0f));
            }
            
        }
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
