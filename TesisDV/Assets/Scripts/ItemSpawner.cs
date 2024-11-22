using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class ItemSpawner : MonoBehaviour
{
    private Dictionary<int, Action<int>> actionItemSpawner;
    [SerializeField] private List<GameObject> _items;
    [SerializeField] private GameObject _blackboard;
    private Blackboard Blackboard;
    [SerializeField] private List<Door> _levelDoors = new List<Door>();   //Despues obtendrán las puertas de otra forma, pero para el dia de hoy sirve.

    void Start()
    {
        _items = new List<GameObject>();
        actionItemSpawner = new Dictionary<int, Action<int>>() 
        { 
            { 0, ActivateTutorialItems }, 
            { 1, ActivateFirstRoundItems }, 
            { 2, ActivateSecondRoundItems },
            { 3, ActivateThirdRoundItems },
            { 4, ActivateFourthRoundItems },
            { 5, ActivateFifthRoundItems },
            { 6, ActivateSixthRoundItems },
            { 7, ActivateSeventhRoundItems },
            { 8, ActivateEighthRoundItems },
            { 9, ActivateNinethRoundItems },
            { 10, ActivateTenthRoundItems }
        };
        GameVars.Values.WaveManager.OnRoundEnd += SpawnItemsImproved;
        transform.GetComponentsInChildren<Transform>(true).Where(items => items.name.Contains("Items")).ToList().ForEach(x => 
        {
            _items.Add(x.gameObject);
        });
        _blackboard = FindObjectsOfType<GameObject>().Where(x => x.name.Equals("DecalsBlackBoardHouse")).FirstOrDefault();
        Blackboard = _blackboard.GetComponentInParent<Blackboard>();
    }
    public void SpawnItemsImproved(int currentRound) { 
        if (actionItemSpawner.TryGetValue(currentRound, out Action<int> action)) 
        { 
            action.Invoke(currentRound); 
        } 
        else 
        { 
            Debug.Log("Action not recognized"); 
        } 
    }
    public void ActivateTutorialItems(int currentRound) 
    {
        ActivateDeactivateItems(currentRound);
        Blackboard.ActiveFirstExperiment();
    }
    public void ActivateFirstRoundItems(int currentRound) 
    {
        ActivateDeactivateItems(currentRound);
    }
    public void ActivateSecondRoundItems(int currentRound)
    {
        GameVars.Values.Cat.CatIsGoingToBasement();
        var blueprintPos = FindObjectsOfType<WorkBenchCraftingMenu>().FirstOrDefault().transform.localPosition;
        //Debug.Log("BLUEPRINT BASEMENT POSITION: " + blueprintPos);
        GameVars.Values.ShowNotification("You can go to the Basement at the Tools Workbench to Buy and Update Traps.",
            blueprintPos);
        GameVars.Values.LevelManager.WorkbenchLight.GetComponentInParent<LightsEmissionHandler>().EnableBasementLightEmission();
        GameVars.Values.LevelManager.WorkbenchLight.SetActive(true);
        Blackboard.ActiveSecondExperiment();
        _levelDoors[2].IsLockedToGrays = false; //Puerta de la cocina a atras de la casa.
        _levelDoors[3].IsLockedToGrays = false; //Puerta de la cocina a un costado de la casa.
        _levelDoors[5].IsLockedToGrays = false; //Puerta de la cocina al living.
        ActivateDeactivateItems(currentRound);
    }
    public void ActivateThirdRoundItems(int currentRound) 
    {
        ActivateDeactivateItems(currentRound);
        Blackboard.ActiveThirdExperiment();
        _levelDoors[1].IsLockedToGrays = false; //Puerta del baño al patio.
        _levelDoors[7].IsLockedToGrays = false; //Puerta del baño al living.
        _levelDoors[8].IsLockedToGrays = false; //Puerta entre el baño y el patio
    }
    private void ActivateFourthRoundItems(int currentRound)
    {
        ActivateDeactivateItems(currentRound);
        GameVars.Values.Cat.CatIsGoingToShed();
        Blackboard.ActiveFourthExperiment();
    }
    private void ActivateFifthRoundItems(int currentRound)
    {
        ActivateDeactivateItems(currentRound);
        FindObjectsOfType<WardrobeDoor>().ToList().ForEach(x => x.IsLocked = false);
        Blackboard.ActiveFifthExperiment();
    }
    private void ActivateSixthRoundItems(int currentRound)
    {
        GameVars.Values.Cat.CatIsGoingToKitchen();
        ActivateDeactivateItems(currentRound);
    }
    private void ActivateSeventhRoundItems(int currentRound)
    {
        ActivateDeactivateItems(currentRound);
    }
    private void ActivateEighthRoundItems(int currentRound)
    {
        ActivateDeactivateItems(currentRound);
    }
    private void ActivateNinethRoundItems(int currentRound)
    {
        ActivateDeactivateItems(currentRound);
    }
    private void ActivateTenthRoundItems(int currentRound)
    {
        ActivateDeactivateItems(currentRound);
    }

    public void ActivateDeactivateItems(int currentRound) 
    {
        _items.Where(itemsToHide => _items.IndexOf(itemsToHide) != currentRound).ToList().ForEach(x =>
        { 
            x.SetActive(false);
        });

        _items.Where(itemsToShow => _items.IndexOf(itemsToShow) == currentRound).FirstOrDefault().SetActive(true);
    }
}
