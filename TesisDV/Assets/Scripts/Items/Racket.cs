using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Racket : Melee
{
    private MeshRenderer _renderer;
    private MeshFilter _meshFilter;
    private bool hitStateActive;
    [SerializeField]
    private bool _isDestroyed;
    
    private Quaternion _startingRotation;
    //public delegate void OnRacketDestroyedDelegate(bool destroyed); Ahora la misma raqueta maneja su GameObject. 
    //public event OnRacketDestroyedDelegate OnRacketDestroyed;
    [SerializeField] private Mesh _damagedRacketMesh;
    [SerializeField] private Mesh _newRacketMesh;
    [SerializeField] private Texture _startingTexture;
    public Texture textureState1;
    public Texture textureState2;
    public Texture textureState3;
    public GameObject racketSpawner;

    void Awake()
    {
        _startingRotation = transform.localRotation;
        hitsRemaining = 7;
        damageAmount = 1;
        SetStateRacketDamaged(hitsRemaining);
        _renderer = transform.GetChild(1).GetComponent<MeshRenderer>();
        _meshFilter = transform.GetChild(1).GetComponent<MeshFilter>();
        //_newRacketMesh = _meshFilter.mesh;
        //_startingTexture = _renderer.material.mainTexture;
    }

    public void OnNewRacketGrabbed()
    {
        this.gameObject.SetActive(true);
        //_isDestroyed = false;
        //hitsRemaining = 7;
        //OnRacketDestroyed?.Invoke(_isDestroyed);
    }

    public override void MeleeAttack()
    {
        if(gameObject.activeSelf && !IsAttacking)
            StartCoroutine(Attack("IsAttacking","RacketSwing"));
    }
    
    IEnumerator Attack(string param, string name)
    {
        IsAttacking = true;
        _player.Cam.ShakeRacketSwing();
        anim.SetBool(param, true);
        GameVars.Values.soundManager.PlaySoundAtPoint("RacketSwing", transform.position, 0.09f);
        var playerCollider = _player.GetComponent<BoxCollider>();
        var clips = anim.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        if (time / 2 < 0.2f)
        {
            playerCollider.enabled = true;
        }
        yield return new WaitForSeconds(time);
        anim.SetBool(param, false);
        playerCollider.enabled = false;
        IsAttacking = false;
        hitStateActive = false;
    }

    /*protected override void OnContactEffect(Collider other)
    {
        if (IsAttacking)
        {
            var enemyGray = other.GetComponent<Enemy>(); //Cambiar a la clase padre despues como todo lo que use para hacer daño.

            //if (other.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer()))
            if (enemyGray)
            {
                //Debug.Log("Hit WITH RACKET TO GRAY?" + other.transform.name);
                hitsRemaining--;
                SetStateRacketDamaged(hitsRemaining);
                if (hitsRemaining <= 0)
                {
                    _isDestroyed = true;
                    GameVars.Values.soundManager.PlaySoundAtPoint("RacketBroken", transform.position, 0.09f);
                    GameVars.Values.ShowNotification("Oh no! The racket has broken!");
                    SetDamagedRacket();
                    //DestroyAndRestoreValues();
                    _player.RacketInventoryRemoved();
                }
                other.GetComponent<Enemy>().TakeDamage(damageAmount);
                IsAttacking = false; //Lo dejo en falso para que no repita el daño, veremos.

                //No usamos observer para hacer daño.
                //AddObserver(other.gameObject.GetComponent<Gray>());
                //TriggerHit("RacketHit");
            }
        }
    }*/
    public override void OnHitEffect()
    {
        if (IsAttacking)
        {
            Debug.Log("Hit WITH RACKET TO GRAY?");
            hitsRemaining--;
            SetStateRacketDamaged(hitsRemaining);
            if (hitsRemaining <= 0)
            {
                _isDestroyed = true;
                GameVars.Values.soundManager.PlaySoundAtPoint("RacketBroken", transform.position, 0.09f);
                GameVars.Values.ShowNotification("Oh no! The racket has broken!");
                SetDamagedRacket();
                //DestroyAndRestoreValues();
                _player.RacketInventoryRemoved();
            }
            IsAttacking = false; //Lo dejo en falso para que no repita el daño, veremos.
        }
    }
    public void RemoveFromParent()
    {
        //var lastWorldPos = transform.parent.parent.position;
        transform.parent.parent = null;
        //transform.position = lastWorldPos;
    }

    public void SetStateRacketDamaged(int hitsRemaining)
    {
        if (hitsRemaining == 5)
        {
            Debug.Log("HITS 5");
            _renderer.material.SetTexture("_MainTexture", textureState1);
        }
        else if (hitsRemaining == 3)
        {
            Debug.Log("HITS 3");
            _renderer.material.SetTexture("_MainTexture", textureState2);
        }
        else if (hitsRemaining == 1)
        {
            Debug.Log("HITS 1");
            _renderer.material.SetTexture("_MainTexture", textureState3);
           
        }
    }

    public void SetDamagedRacket()
    {
        _meshFilter.mesh = _damagedRacketMesh;
        anim.SetBool("IsDestroyed", true);
        transform.localRotation = Quaternion.Euler(2.658f,42.094f,73.143f);
    }

    public void DestroyAndRestoreValues()
    {
        this.gameObject.SetActive(false);
        
        hitsRemaining = 7; //Hacer un void ResetHits() despues.
        transform.localRotation = _startingRotation;
        transform.parent.parent = _player.Cam.transform;
        transform.parent.localPosition = Vector3.zero;
        transform.parent.localRotation = Quaternion.Euler(0f,0f,0f);
        anim.SetBool("IsDestroyed", false);
        _meshFilter.mesh = _newRacketMesh;
        _renderer.material.SetTexture("_MainTexture", _startingTexture);
        SetStateRacketDamaged(hitsRemaining);
    }
    
}
