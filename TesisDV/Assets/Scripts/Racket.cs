using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Racket : Melee
{
    [SerializeField]
    private ParticleSystem _trail;
    private MeshRenderer _renderer;
    private MeshFilter _meshFilter;
    private bool hitStateActive;
    [SerializeField]
    private bool _isDestroyed;
    [SerializeField]
    private int _damageAmount = 1;
    private Quaternion _startingRotation;
    //public delegate void OnRacketDestroyedDelegate(bool destroyed); Ahora la misma raqueta maneja su GameObject. 
    //public event OnRacketDestroyedDelegate OnRacketDestroyed;
    [SerializeField] private Mesh _damagedRacketMesh;
    private Mesh _newRacketMesh;
    private Texture _startingTexture;
    public Texture textureState1;
    public Texture textureState2;
    public Texture textureState3;

    void Awake()
    {
        _startingRotation = transform.localRotation;
        hitsRemaining = 7;
        SetStateRacketDamaged(hitsRemaining);
        _renderer = GetComponent<MeshRenderer>();
        _meshFilter = GetComponent<MeshFilter>();
        _newRacketMesh = _meshFilter.mesh;
        _startingTexture = _renderer.material.mainTexture;
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
        if(!IsAttacking)
            StartCoroutine(Attack("IsAttacking","RacketSwing"));
    }
    
    IEnumerator Attack(string param, string name)
    {
        IsAttacking = true;
        _player.Cam.ShakeRacketSwing();
        _trail.gameObject.SetActive(IsAttacking);
        _trail.Play();
        anim.SetBool(param, true);
        GameVars.Values.soundManager.PlaySoundAtPoint("RacketSwing", transform.position, 0.09f);

        var clips = anim.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        yield return new WaitForSeconds(time);
        anim.SetBool(param, false);
        _trail.Stop();

        IsAttacking = false;
        hitStateActive = false;
        _trail.gameObject.SetActive(IsAttacking);
    }

    protected override void OnContactEffect(Collider other)
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
                    //OnRacketDestroyed?.Invoke(_isDestroyed);
                    DestroyAndRestoreValues();
                    _player.RacketInventoryRemoved();
                }
                other.GetComponent<Enemy>().TakeDamage(_damageAmount);
                IsAttacking = false; //Lo dejo en falso para que no repita el daño, veremos.

                //No usamos observer para hacer daño.
                //AddObserver(other.gameObject.GetComponent<Gray>());
                //TriggerHit("RacketHit");
            }
        }
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
            SetDamagedRacket();
        }
    }

    public void SetDamagedRacket()
    {
        _meshFilter.mesh = _damagedRacketMesh;
        //transform.position -= 0.07f;
        transform.localRotation = Quaternion.Euler(2.658f,42.094f,73.143f);
    }

    public void DestroyAndRestoreValues()
    {
        this.gameObject.SetActive(false);
        hitsRemaining = 7; //Hacer un void ResetHits() despues.
        transform.localRotation = _startingRotation;
        _meshFilter.mesh = _newRacketMesh;
        _renderer.material.SetTexture("_MainTexture", _startingTexture);
        SetStateRacketDamaged(hitsRemaining);
    }
    
}
