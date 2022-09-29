using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemSpawner : MonoBehaviour
{
    [SerializeField] private GameObject _firstRoundItems;
    [SerializeField] private GameObject _secondRoundItems;
    [SerializeField] private GameObject _thirdRoundItems;

    void Start()
    {
        GameVars.Values.WaveManager.OnRoundEnd += SpawnItems;
        _firstRoundItems =  transform.GetChild(0).gameObject;
        _secondRoundItems = transform.GetChild(1).gameObject;
        _thirdRoundItems =  transform.GetChild(2).gameObject;
    }

    private void SpawnItems(int currentRound)
    {
        switch(currentRound)
        {
            case 0:
                    _firstRoundItems.SetActive(true);
            break;
            case 1:
                    //_firstRoundItems.SetActive(false);
                    _secondRoundItems.SetActive(true);
            break;
            case 2:
                    //_secondRoundItems.SetActive(false);
                    _thirdRoundItems.SetActive(true);
            break;
        }
    }
}
