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
    [SerializeField] private int _totalGraysUFO1;

    [Header("UFO 2 Details")]

    [SerializeField] private Vector3 _finalPos2;

    [SerializeField] private int _totalGraysUFO2;

    [SerializeField] private GameObject UFOIndicatorPrefab;
    private GameObject UFOIndicator;
    private GameObject UFOIndicator2;
    public delegate void OnRoundChangedDelegate(int newVal);
    public event OnRoundChangedDelegate OnRoundChanged;
    public delegate void OnTimeWaveChangeDelegate(float newVal);
    public event OnTimeWaveChangeDelegate OnTimeWaveChange;
    public delegate void OnRoundStartEndDelegate(bool roundStart);
    public event OnRoundStartEndDelegate OnRoundStartEnd;
    public delegate void OnRoundEndDelegate();
    public event OnRoundEndDelegate OnRoundEnd;

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
        OnRoundEnd();
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

    IEnumerator WaitBetweenWaves()
    {
        DespawnUFOIndicators();
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

        DespawnUFOIndicators();
        SpawnWave();
        GameVars.Values.soundManager.PlaySound("MusicWaves", 0.16f, true);
        //_inRound = true;
        //OnRoundStartEnd?.Invoke(_inRound);
        TimeWaves = _timeBetweenWaves;
    }

    private void SpawnWave()
    {
        InstantiateUFOIndicators();
        if (_currentRound < _totalRounds)
        {
            CurrentRound++;
            //TriggerRoundChange("RoundChanged");
            Instantiate(_myUFO, parent.transform).SetSpawnPos(_startingPos).SetFinalPos(_finalPos1).SetTotalGrays(_totalGraysUFO1);//.SetRotation(new Vector3(-90f, 0f, 0f));
            Instantiate(_myUFO, parent.transform).SetSpawnPos(_startingPos).SetFinalPos(_finalPos2).SetTotalGrays(_totalGraysUFO2);//.SetRotation(new Vector3(-90f, 0f, 0f));
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
            Invoke("SendWinGame", 1f);
            return;
        }
        _inRound = false;
        OnRoundStartEnd?.Invoke(_inRound);
        OnRoundEnd();
        //if(_currentCoroutine != null) StopCoroutine(_currentCoroutine);
        //_currentCoroutine = StartCoroutine("WaitBetweenWaves");
    }

    private void DespawnUFOIndicators()
    {
        Destroy(UFOIndicator);
        Destroy(UFOIndicator2);
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
