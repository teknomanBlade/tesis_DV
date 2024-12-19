using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using System.Linq;

public class Door : Item
{
    protected Animator _anim;
    [SerializeField]
    protected Animator _animParent;
    [SerializeField] protected BoxCollider _collider;
    private float _valueToChange;
    private NavMeshObstacle _navMeshObstacle;
    protected bool IsOpened { get; set; }
    public bool IsLocked;
    public bool IsLockedToGrays;
    public bool IsEnemyInteracting;
    public bool IsFront = false;
    public DoorTrigger[] doorTriggers;
    // Start is called before the first frame update
    void Awake()
    {
        _anim = GetComponent<Animator>();
        _animParent = transform.parent.GetComponent<Animator>();
        _collider = GetComponent<BoxCollider>();
        doorTriggers = GetComponentsInChildren<DoorTrigger>();
        itemType = ItemType.Interactable;
        //_navMeshObstacle = GetComponent<NavMeshObstacle>();
    }

    IEnumerator LerpDoorAnim(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;
        
        if (IsFront)
        {
            while (time < duration)
            {
                _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
                time += Time.deltaTime;

                _anim.SetFloat("Anim", _valueToChange);
                yield return null;
            }
        }
        else
        {
            while (time < duration)
            {
                _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
                time += Time.deltaTime;

                _anim.SetFloat("Blend", _valueToChange);
                yield return null;
            }
        }
        if(!IsOpened)
            doorTriggers.Select(x => x).ToList().ForEach(x => x.gameObject.SetActive(true));

        _valueToChange = endValue;
    }

    public override void Interact()
    {
        StopAllCoroutines();
        doorTriggers.Select(x => x).ToList().ForEach(x => x.gameObject.SetActive(false));

        if (IsLocked)
        {
            if (transform.CompareTag("Tutorial"))
            {
                GameVars.Values.ShowNotification("You can't go out now." + GameVars.Values.ShowMessageNotificationByAction());
            }
            _anim.SetBool("IsBlocked", true);
            GameVars.Values.soundManager.PlaySoundAtPoint("LockedDoorTry_" + RandomSound(), transform.position, 0.4f);
            Invoke("SetBlockedFalse", 0.5f);
            return;
        }

        if (IsEnemyInteracting)
        {
            if (transform.CompareTag("Tutorial") && IsEnemyInteracting)
            {
                GameVars.Values.PassedTutorial = IsEnemyInteracting;
                Debug.Log("PASSED TUTORIAL ENEMY INTERACTING = " + IsEnemyInteracting);
            }
            if (_animParent != null)
                _animParent.SetBool("IsDropped", true);
            GameVars.Values.soundManager.PlaySoundAtPoint("SFX_DoorSlammed", transform.position, 0.4f);
            _collider.enabled = false;
        }
        else 
        {
            if (!IsOpened)
            {
                IsOpened = true;
                if (transform.CompareTag("Tutorial") && IsOpened)
                {
                    GameVars.Values.PassedTutorial = IsOpened;
                    GameVars.Values.IsTutorial = IsOpened;
                }
                GameVars.Values.soundManager.PlaySoundAtPoint("OpenDoor", transform.position, 0.4f);
                //_navMeshObstacle.enabled = false;
                StartCoroutine(LerpDoorAnim(1f, 2f));
            }
            else
            {
                IsOpened = false;
                GameVars.Values.soundManager.PlaySoundAtPoint("CloseDoor", transform.position, 0.4f);
                //_navMeshObstacle.enabled = true;
                StartCoroutine(LerpDoorAnim(0f, 2f));
            }
        }
    }
    public void EnemyInteractionCheck(bool enabled) 
    {
        IsEnemyInteracting = enabled;
    }
    private void SetBlockedFalse()
    {
        _anim.SetBool("IsBlocked", false);
    }

    protected string RandomSound()
    {
        return UnityEngine.Random.Range(1,3).ToString();
    }

    public bool GetDoorStatus()
    {
        return IsOpened;
    }

    internal void OnEnemyDoorInteract()
    {
        IsLocked = false;
        EnemyInteractionCheck(true);
        Interact();
    }
}

public enum EnumDoor
{
    IsPlayerBack,
    IsPlayerFront
}
