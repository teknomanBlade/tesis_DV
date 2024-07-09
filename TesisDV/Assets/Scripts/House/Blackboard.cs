using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Blackboard : MonoBehaviour
{
    private Animator _animator;
    private RectTransform _trapsPanel;
    private RectTransform _trap1;
    private RectTransform _trap2;
    private RectTransform _trap3;
    private RectTransform _trap4;
    private RectTransform _trap5;
    // Start is called before the first frame update
    void Start()
    {
        _animator = GetComponent<Animator>();
        _trapsPanel = FindObjectsOfType<RectTransform>(true).Where(x => x.name.Equals("InventoryAndTrapDescriptions")).FirstOrDefault();
        _trap1 = GetTrap("Trap 1");
        _trap2 = GetTrap("Trap 2");
        _trap2.gameObject.SetActive(false);
        _trap3 = GetTrap("Trap 3");
        _trap3.gameObject.SetActive(false);
        _trap4 = GetTrap("Trap 4");
        _trap4.gameObject.SetActive(false);
        _trap5 = GetTrap("Trap 5");
        _trap5.gameObject.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    private RectTransform GetTrap(string name) 
    {
        return _trapsPanel.GetComponentsInChildren<RectTransform>(true).Where(x => x.name.Equals(name)).FirstOrDefault();
    }
    public void ActiveFirstExperiment()
    {
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
    }

    public void ActiveSecondExperiment() 
    {
        _animator.SetBool("IsSecondExperiment", true);
        _trap2.gameObject.SetActive(true);
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!");
    }
    public void ActiveThirdExperiment()
    {
        _animator.SetBool("IsSecondExperiment", false);
        _animator.SetBool("IsThirdExperiment", true);
        _trap3.gameObject.SetActive(true);
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!");
    }
    public void ActiveFourthExperiment()
    {
        _animator.SetBool("IsThirdExperiment", false);
        _animator.SetBool("IsFourthExperiment", true);
        _trap4.gameObject.SetActive(true);
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!");
    }
    public void ActiveFifthExperiment()
    {
        _animator.SetBool("IsFourthExperiment", false);
        _animator.SetBool("IsFifthExperiment", true);
        _trap5.gameObject.SetActive(true);
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!");
    }
}
