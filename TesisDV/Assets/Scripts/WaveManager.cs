using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveManager : MonoBehaviour, IRoundChangeObservable
{
    private List<IRoundChangeObserver> roundChangeObservers = new List<IRoundChangeObserver>();

    private Coroutine _currentCoroutine;

    [SerializeField]
    private UFO _myUFO;

    [Header("Wave Details")]
    [SerializeField]
    private int _currentRound;
    [SerializeField]
    private float _firstWaveDelay;
    [SerializeField]
    private float _timeBetweenWaves;
    [SerializeField]
    private int _totalRounds;

    [SerializeField]
    private Vector3 _startingPos;

    [Header("UFO 1 Details")]
    [SerializeField]
    private Vector3 _finalPos1;
    [SerializeField]
    private int _totalGraysUFO1;

    [Header("UFO 2 Details")]

    [SerializeField]
    private Vector3 _finalPos2;

    [SerializeField]
    private int _totalGraysUFO2;

    [SerializeField]
    private GameObject UFOIndicatorPrefab;
    private GameObject UFOIndicator;
    private GameObject UFOIndicator2;

    void Awake()
    {
        InstantiateUFOIndicators();
        _currentCoroutine = StartCoroutine("WaitFirstDelay");
    }

    void Update()
    {

    }

    IEnumerator WaitFirstDelay()
    {
        yield return new WaitForSeconds(_firstWaveDelay);
        SpawnWave();
        GameVars.Values.soundManager.PlaySound("MusicWaves", 0.16f, true);
    }

    IEnumerator WaitBetweenWaves()
    {
        yield return new WaitForSeconds(_timeBetweenWaves);
        SpawnWave();
    }

    private void SpawnWave()
    {
        DespawnUFOIndicators();
        if(_currentRound <= _totalRounds)
        {
            _currentRound++;
            TriggerRoundChange("RoundChanged");
            Instantiate(_myUFO).SetSpawnPos(_startingPos).SetFinalPos(_finalPos1).SetTotalGrays(_totalGraysUFO1);//.SetRotation(new Vector3(-90f, 0f, 0f));
            Instantiate(_myUFO).SetSpawnPos(_startingPos).SetFinalPos(_finalPos2).SetTotalGrays(_totalGraysUFO2);//.SetRotation(new Vector3(-90f, 0f, 0f));
        }
        else
        {
            GameVars.Values.LevelManager.WinGame();
        }
    }

    //Hacer por evento en lugar de void publico.
    public void SendNextRound()
    {
        InstantiateUFOIndicators();
        if(_currentCoroutine != null) StopCoroutine(_currentCoroutine);
        _currentCoroutine = StartCoroutine("WaitBetweenWaves");
    }

    private void DespawnUFOIndicators()
    {
        Destroy(UFOIndicator);
        Destroy(UFOIndicator2);
    }

    private void InstantiateUFOIndicators()
    {
        Vector3 auxVector = new Vector3(_finalPos1.x, 0f, _finalPos1.z);
        UFOIndicator = Instantiate(UFOIndicatorPrefab);
        UFOIndicator.transform.position = auxVector;
        Vector3 auxVector2 = new Vector3(_finalPos2.x, 0f, _finalPos2.z);
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
