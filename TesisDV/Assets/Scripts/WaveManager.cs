using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveManager : MonoBehaviour, IRoundChangeObservable
{
    private List<IRoundChangeObserver> roundChangeObservers = new List<IRoundChangeObserver>();

    [SerializeField]
    private UFO _myUFO;

    [Header("Wave Details")]
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

    void Start()
    {
       StartCoroutine("WaitFirstDelay");
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
        StartCoroutine("WaitBetweenWaves");
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