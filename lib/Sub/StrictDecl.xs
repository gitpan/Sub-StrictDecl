#define PERL_NO_GET_CONTEXT 1
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef newSVpvs_share
# ifdef newSVpvn_share
#  define newSVpvs_share(STR) newSVpvn_share(""STR"", sizeof(STR)-1, 0)
# else /* !newSVpvn_share */
#  define newSVpvs_share(STR) newSVpvn(""STR"", sizeof(STR)-1)
#  define SvSHARED_HASH(SV) 0
# endif /* !newSVpvn_share */
#endif /* !newSVpvs_share */

#ifndef SvSHARED_HASH
# define SvSHARED_HASH(SV) SvUVX(SV)
#endif /* !SvSHARED_HASH */

#ifndef SVfARG
# define SVfARG(p) ((void*)(p))
#endif /* !SVfARG */

#ifndef qerror
# define qerror(m) Perl_qerror(aTHX_ m)
#endif /* !qerror */

static SV *hint_key_sv;
static U32 hint_key_hash;
static OP *(*nxck_rv2cv)(pTHX_ OP *o);

#define in_strictdecl() THX_in_strictdecl(aTHX)
static bool THX_in_strictdecl(pTHX)
{
	HE *ent = hv_fetch_ent(GvHV(PL_hintgv), hint_key_sv, 0, hint_key_hash);
	return ent && SvTRUE(HeVAL(ent));
}

static OP *myck_rv2cv(pTHX_ OP *op)
{
	OP *aop;
	GV *gv;
	op = nxck_rv2cv(aTHX_ op);
	if(op->op_type == OP_RV2CV && (op->op_flags & OPf_KIDS) &&
			(aop = cUNOPx(op)->op_first) && aop->op_type == OP_GV &&
			in_strictdecl() &&
			(gv = cGVOPx_gv(aop)) && !GvCVu(gv)) {
		SV *name = sv_newmortal();
		gv_efullname3(name, gv, NULL);
		qerror(mess("Undeclared subroutine &%"SVf"", SVfARG(name)));
	}
	return op;
}

MODULE = Sub::StrictDecl PACKAGE = Sub::StrictDecl

PROTOTYPES: DISABLE

BOOT:

	hint_key_sv = newSVpvs_share("Sub::StrictDecl/strict");
	hint_key_hash = SvSHARED_HASH(hint_key_sv);
	nxck_rv2cv = PL_check[OP_RV2CV]; PL_check[OP_RV2CV] = myck_rv2cv;

void
import(SV *classname)
PREINIT:
	SV *val;
	HE *he;
CODE:
	PERL_UNUSED_VAR(classname);
	PL_hints |= HINT_LOCALIZE_HH;
	gv_HVadd(PL_hintgv);
	val = newSVsv(&PL_sv_yes);
	he = hv_store_ent(GvHV(PL_hintgv), hint_key_sv, val, hint_key_hash);
	if(he) {
		val = HeVAL(he);
		SvSETMAGIC(val);
	} else {
		SvREFCNT_dec(val);
	}

void
unimport(SV *classname)
CODE:
	PERL_UNUSED_VAR(classname);
	PL_hints |= HINT_LOCALIZE_HH;
	gv_HVadd(PL_hintgv);
	(void) hv_delete_ent(GvHV(PL_hintgv), hint_key_sv, G_DISCARD,
		hint_key_hash);
