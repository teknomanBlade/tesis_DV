using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class ItemSpawner : MonoBehaviour
{
    [SerializeField] private GameObject _tutorialRoundItems;
    [SerializeField] private GameObject _firstRoundItems;
    [SerializeField] private GameObject _secondRoundItems;
    [SerializeField] private GameObject _thirdRoundItems;
    [SerializeField] private GameObject _fourthRoundItems;
    [SerializeField] private GameObject _fifthRoundItems;
    [SerializeField] private GameObject _sixthRoundItems;
    [SerializeField] private GameObject _blackboard;
    private Coroutine FadeInSceneCoroutine;
    [SerializeField] private List<Door> _levelDoors = new List<Door>();   //Despues obtendrán las puertas de otra forma, pero para el dia de hoy sirve.

    void Start()
    {
        GameVars.Values.WaveManager.OnRoundEnd += SpawnItems;
        _tutorialRoundItems = transform.GetChild(0).gameObject;
        _firstRoundItems =  transform.GetChild(1).gameObject;
        _secondRoundItems = transform.GetChild(2).gameObject;
        _thirdRoundItems =  transform.GetChild(3).gameObject;
        _fourthRoundItems = transform.GetChild(4).gameObject;
        _fifthRoundItems = transform.GetChild(5).gameObject;
        _sixthRoundItems = transform.GetChild(6).gameObject;
        _blackboard = FindObjectsOfType<GameObject>().Where(x => x.name.Equals("DecalsBlackBoardHouse")).FirstOrDefault();
        _blackboard.GetComponent<MeshRenderer>().material.EnableKeyword("_SwitchExperiment_Key0");
        _blackboard.GetComponent<MeshRenderer>().material.shaderKeywords.ToList().ForEach(x => Debug.Log(x));
        Debug.Log("KEYWORD FIRST TO SECOND ENABLED? " + _blackboard.GetComponent<MeshRenderer>().material.IsKeywordEnabled("_SwitchExperiment_Key0"));
        
    }

    private void SpawnItems(int currentRound)
    {
        switch(currentRound)
        {
            case 0:
                _tutorialRoundItems.SetActive(true);
                break;
            case 1:
                _firstRoundItems.SetActive(true);
                ActiveFadeInExperiment("_FirstToSecond",1f);
                break;
            case 2:
                _blackboard.GetComponent<MeshRenderer>().material.DisableKeyword("_SwitchExperiment_Key0");
                _blackboard.GetComponent<MeshRenderer>().material.EnableKeyword("_SwitchExperiment_Key1");
                Debug.Log("KEYWORD SECOND TO THIRD ENABLED? " + _blackboard.GetComponent<MeshRenderer>().material.IsKeywordEnabled("_SwitchExperiment_Key1"));
                GameVars.Values.ShowNotificationDefinedTime("You can go to the Basement at the Tools Workbench to Buy and Update Traps.", 4.5f, () => ActivateSecondWaveItems());
                _levelDoors[2].IsLockedToGrays = false; //Puerta de la cocina a atras de la casa.
                _levelDoors[3].IsLockedToGrays = false; //Puerta de la cocina a un costado de la casa.
                _levelDoors[5].IsLockedToGrays = false; //Puerta de la cocina al living.
                break;
            case 3:
                _thirdRoundItems.SetActive(true);
                _levelDoors[1].IsLockedToGrays = false; //Puerta del baño al patio.
                _levelDoors[7].IsLockedToGrays = false; //Puerta del baño al living.
                _levelDoors[8].IsLockedToGrays = false; //Puerta entre el baño y el patio
                break;
            case 4:
                _fourthRoundItems.SetActive(true);
                _blackboard.GetComponent<MeshRenderer>().material.EnableKeyword("_SwitchExperiment_Key2");
                ActiveFadeInExperiment("_ThirdToFourth", 1f);
                break;
            case 5:
                _fifthRoundItems.SetActive(true);
                _blackboard.GetComponent<MeshRenderer>().material.EnableKeyword("_SwitchExperiment_Key3");
                ActiveFadeInExperiment("_FourthToFifth", 1f);
                break;
            case 6:
                _sixthRoundItems.SetActive(true);
                break;
        }
    }
    public void ActiveFadeInExperiment(string param,float duration) 
    {
        if (FadeInSceneCoroutine != null) StopCoroutine(FadeInSceneCoroutine);
        FadeInSceneCoroutine = StartCoroutine(LerpFadeInEffect(param,duration));
    }
    IEnumerator LerpFadeInEffect(string param,float duration)
    {
        float time = 0f;

        while (time < duration)
        {
            time += Time.deltaTime;

            _blackboard.GetComponent<MeshRenderer>().material.SetFloat(param, Mathf.Clamp01(time / duration));
            yield return null;
        }
    }
    public void ActivateSecondWaveItems()
    {
        GameVars.Values.BasementDirectionMarkers.SetActive(true);
        GameVars.Values.LevelManager.WorkbenchLight.SetActive(true);
        ActiveFadeInExperiment("_SecondToThird", 1f);
        _secondRoundItems.SetActive(true);
    }
}
