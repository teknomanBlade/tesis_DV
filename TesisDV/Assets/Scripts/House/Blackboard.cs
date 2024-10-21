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
    private bool IsTrap2StageEnabled;
    private bool IsTrap3StageEnabled;
    private bool IsTrap4StageEnabled;
    private bool IsTrap5StageEnabled;
    private AudioSource _as;

    // Start is called before the first frame update
    void Start()
    {
        _animator = GetComponent<Animator>();
        _as = GetComponent<AudioSource>();
        IsTrap2StageEnabled = false;
        IsTrap3StageEnabled = false;
        IsTrap4StageEnabled = false;
        IsTrap5StageEnabled = false;
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
        IsTrap2StageEnabled = true;
        
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!", transform.localPosition);
    }
    public void ActiveThirdExperiment()
    {
        _animator.SetBool("IsSecondExperiment", false);
        _animator.SetBool("IsThirdExperiment", true);
        IsTrap3StageEnabled = true;
        GetComponent<BoxCollider>().enabled = IsTrap3StageEnabled;
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!", transform.localPosition);
    }
    public void ActiveFourthExperiment()
    {
        _animator.SetBool("IsThirdExperiment", false);
        _animator.SetBool("IsFourthExperiment", true);
        IsTrap4StageEnabled = true;
        GetComponent<BoxCollider>().enabled = IsTrap4StageEnabled;
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!", transform.localPosition);
    }
    public void ActiveFifthExperiment()
    {
        _animator.SetBool("IsFourthExperiment", false);
        _animator.SetBool("IsFifthExperiment", true);
        IsTrap5StageEnabled = true;
        GetComponent<BoxCollider>().enabled = IsTrap5StageEnabled;
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!", transform.localPosition);
    }

    private void OnTriggerEnter(Collider other)
    {
        var player = other.gameObject.GetComponent<Player>();
        if (player) 
        {
            Debug.Log("ENTRO EL PLAYER AL" + gameObject.name + "?");
            if (IsTrap2StageEnabled) 
            {
                _trap2.gameObject.SetActive(true);
                GetComponent<BoxCollider>().enabled = false;
                GameVars.Values.soundManager.PlaySound(_as,"SFX_MagicboardWriting", 0.6f, false,1f);
                GameVars.Values.ShowNotification("You have new Traps to Build! Check the Magicboard! (Tab)");
            }
            if (IsTrap3StageEnabled)
            {
                _trap3.gameObject.SetActive(true);
                GetComponent<BoxCollider>().enabled = false;
                GameVars.Values.soundManager.PlaySound(_as, "SFX_MagicboardWriting", 0.6f, false, 1f);
                GameVars.Values.ShowNotification("You have new Traps to Build! Check the Magicboard! (Tab)");
            }
            if (IsTrap4StageEnabled)
            {
                _trap4.gameObject.SetActive(true);
                GetComponent<BoxCollider>().enabled = false;
                GameVars.Values.soundManager.PlaySound(_as, "SFX_MagicboardWriting", 0.6f, false, 1f);
                GameVars.Values.ShowNotification("You have new Traps to Build! Check the Magicboard! (Tab)");
            }
            if (IsTrap5StageEnabled)
            {
                _trap5.gameObject.SetActive(true);
                GetComponent<BoxCollider>().enabled = false;
                GameVars.Values.soundManager.PlaySound(_as, "SFX_MagicboardWriting", 0.6f, false, 1f);
                GameVars.Values.ShowNotification("You have new Traps to Build! Check the Magicboard! (Tab)");
            }
        }
    }
}
